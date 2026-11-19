-- Core query: workshops that can fix a fault code for a given brand,
-- ordered from nearest to farthest.
--
-- Inputs (change these values to test):
--   fault code     -> 'P0700'
--   vehicle brand  -> 'Toyota'
--   user position  -> latitude 37.8450, longitude 27.8400 (Aydin)
--
-- distance_score is not in km. It is a squared distance in degrees,
-- good enough for ordering inside one city. Longitude differences are
-- multiplied by 0.79 because at Aydin's latitude (about 37.8 degrees)
-- one degree of longitude is about 79% as long as one degree of latitude.

SELECT w.name,
       w.address,
       f.specialty_name,
       (w.latitude - 37.8450) * (w.latitude - 37.8450)
     + ((w.longitude - 27.8400) * 0.79) * ((w.longitude - 27.8400) * 0.79)
         AS distance_score
FROM fault_code f
JOIN has_specialty h ON h.specialty_name = f.specialty_name
JOIN workshop w      ON w.workshop_id    = h.workshop_id
JOIN serves_brand sb ON sb.workshop_id   = w.workshop_id
WHERE f.code = 'P0700'
  AND sb.brand_name = 'Toyota'
ORDER BY distance_score;
