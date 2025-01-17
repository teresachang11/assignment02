WITH wheelchair_boarding AS (
    SELECT
        nbh.name,
        COUNT(stops.stop_id) AS count
    FROM azavea.neighborhoods AS nbh
    INNER JOIN septa.bus_stops AS stops ON ST_INTERSECTS(stops.geog, nbh.geog)
    WHERE stops.wheelchair_boarding = 1
    GROUP BY nbh.name
),

ratio AS (
    SELECT
        nbh.name,
        COUNT(stops.stop_id)::FLOAT AS tot_stops,
        (w.count / COUNT(stops.stop_id)::FLOAT) * 0.7 + ((w.count / nbh.shape_area) * 10 ^ 5 / 0.787) * 0.3 AS accessibility_metric
    FROM azavea.neighborhoods AS nbh
    INNER JOIN septa.bus_stops AS stops ON ST_INTERSECTS(stops.geog, nbh.geog)
    LEFT JOIN wheelchair_boarding AS w ON nbh.name = w.name
    GROUP BY nbh.name, w.count, nbh.shape_area
)

SELECT
    r.name AS neighborhood_name,
    r.accessibility_metric,
    w.count AS num_bus_stops_accessible,
    r.tot_stops - w.count AS num_bus_stops_inaccessible
FROM ratio AS r
INNER JOIN wheelchair_boarding AS w ON w.name = r.name
ORDER BY r.accessibility_metric ASC
LIMIT 5
