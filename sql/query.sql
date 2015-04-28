/*
WITH ls AS (
 SELECT g.nummer, g.nbident, g.egris_egrid, l.geometrie, l.gem_bfs
 FROM av_avdpool_ch.liegenschaften_grundstueck as g, av_avdpool_ch.liegenschaften_liegenschaft as l
 WHERE g.tid = l.liegenschaft_von
),

pt AS (
 SELECT ST_PointFromText('POINT(614880 225989)', 21781) as geom
)

SELECT *
FROM ls, pt
WHERE ls.geometrie && pt.geom
AND ST_Intersects(ls.geometrie, pt.geom)

-- versus

SELECT nummer, nbident, egris_egrid, geometrie, bfsnr
FROM av_mopublic.liegenschaften__liegenschaft
WHERE geometrie && ST_PointFromText('POINT(614880 225989)', 21781)
AND ST_Intersects(geometrie, ST_PointFromText('POINT(614880 225989)', 21781))

-- versus

SELECT nummer, nbident, egris_egrid, geometrie, bfsnr
FROM av_mopublic.liegenschaften__liegenschaft
WHERE ST_Intersects(geometrie, ST_PointFromText('POINT(614880 225989)', 21781))

*/
------------------

SELECT round(ST_Area(geom)::numeric, 2) anteil, art, geom
FROM
(
 SELECT ST_Union(geom) as geom, art
 FROM 
 (
  SELECT geom, art
  FROM
  (
   SELECT ST_Multi(ST_CollectionExtract(ST_Intersection(bb.geometrie, ls.geometrie),3)) as geom, bb.art
   FROM av_mopublic.bodenbedeckung__boflaeche as bb, 
   (
    SELECT nummer, nbident, egris_egrid, geometrie, bfsnr
    FROM av_mopublic.liegenschaften__liegenschaft
    WHERE ST_Intersects(geometrie, ST_PointFromText('POINT(614880 225989)', 21781))
   ) as ls
   WHERE ST_Intersects(bb.geometrie, ls.geometrie)
  ) as i
  WHERE GeometryType(geom) = 'MULTIPOLYGON'
  AND geom IS NOT NULL
  AND ST_IsValid(geom) 
 ) as j
 GROUP BY art
) as k







--WHERE ST_Distance(bofl.geometrie, j.point) = 0







