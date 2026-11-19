"""Fault-to-Workshop: find the nearest workshop that can fix a car fault code.

All data is fictional and created for testing.
"""

import sqlite3
from math import asin, cos, radians, sin, sqrt
from pathlib import Path

import pandas as pd
import streamlit as st

BASE_DIR = Path(__file__).parent
DB_PATH = BASE_DIR / "workshop.db"

# Default user position: Efeler, Aydın (demo value)
DEFAULT_LAT = 37.8450
DEFAULT_LON = 27.8400


def build_database():
    """Create workshop.db from schema.sql and seed.sql if it does not exist yet."""
    if DB_PATH.exists():
        return
    conn = sqlite3.connect(DB_PATH)
    conn.executescript((BASE_DIR / "schema.sql").read_text(encoding="utf-8"))
    conn.executescript((BASE_DIR / "seed.sql").read_text(encoding="utf-8"))
    conn.close()


def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def distance_km(lat1, lon1, lat2, lon2):
    """Great-circle distance between two points (haversine formula)."""
    earth_radius_km = 6371
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    return 2 * earth_radius_km * asin(sqrt(a))


def find_workshops(conn, code, brand, lat, lon):
    """Workshops that have the specialty the fault code needs and serve the brand."""
    query = """
        SELECT w.name, w.address, w.latitude, w.longitude
        FROM fault_code f
        JOIN has_specialty h ON h.specialty_name = f.specialty_name
        JOIN workshop w      ON w.workshop_id    = h.workshop_id
        JOIN serves_brand sb ON sb.workshop_id   = w.workshop_id
        WHERE f.code = :code
          AND sb.brand_name = :brand
        ORDER BY (w.latitude - :lat) * (w.latitude - :lat)
               + ((w.longitude - :lon) * 0.79) * ((w.longitude - :lon) * 0.79)
    """
    rows = conn.execute(query, {"code": code, "brand": brand, "lat": lat, "lon": lon}).fetchall()
    return [
        {
            "Workshop": name,
            "Address": address,
            "Distance (km)": round(distance_km(lat, lon, w_lat, w_lon), 2),
            "lat": w_lat,
            "lon": w_lon,
        }
        for name, address, w_lat, w_lon in rows
    ]


# ---------- Page ----------

build_database()
conn = get_connection()

st.title("🚗 Fault-to-Workshop")
st.caption("Find the nearest workshop that can fix your car's fault code. Demo with fictional data.")

# code -> (description, urgency, specialty)
fault_info = {
    code: (description, urgency, specialty)
    for code, description, urgency, specialty in conn.execute(
        "SELECT code, description, urgency, specialty_name FROM fault_code ORDER BY code"
    )
}
brands = [row[0] for row in conn.execute("SELECT name FROM brand ORDER BY name")]

# Start with a combination that has a result, so the first view is not empty
codes = list(fault_info)
code = st.selectbox(
    "Fault code",
    codes,
    index=codes.index("P0562"),
    format_func=lambda c: f"{c} – {fault_info[c][0]}",
)
brand = st.selectbox("Car brand", brands, index=brands.index("Fiat"))

with st.expander("Your location"):
    lat = st.number_input("Latitude", value=DEFAULT_LAT, format="%.4f")
    lon = st.number_input("Longitude", value=DEFAULT_LON, format="%.4f")

description, urgency, specialty = fault_info[code]
message = f"**{code}** · {description} — needs a workshop with **{specialty}** specialty."
if urgency == "high":
    st.error(f"High urgency · {message}")
elif urgency == "medium":
    st.warning(f"Medium urgency · {message}")
else:
    st.info(f"Low urgency · {message}")

results = find_workshops(conn, code, brand, lat, lon)

if not results:
    st.warning(f"No workshop found that handles {specialty} for {brand}.")
else:
    df = pd.DataFrame(results)
    st.subheader(f"{len(results)} matching workshop(s)")
    st.dataframe(df[["Workshop", "Address", "Distance (km)"]], hide_index=True)
    st.map(df[["lat", "lon"]])

conn.close()
