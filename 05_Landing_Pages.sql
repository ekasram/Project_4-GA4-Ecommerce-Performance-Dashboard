WITH events AS (
  SELECT
    CONCAT(user_pseudo_id, '-',
      (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')
    ) AS session_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_location,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'entrances') AS entrances,
    event_name,
    ecommerce.purchase_revenue_in_usd AS revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
),
sessions AS (
  SELECT
    session_id,
    MAX(CASE WHEN entrances = 1 THEN page_location END) AS landing_page,
    MAX(CASE WHEN event_name = 'session_start' THEN 1 ELSE 0 END) AS is_visit,
    MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS is_purchase,
    SUM(CASE WHEN event_name = 'purchase' THEN revenue ELSE 0 END) AS session_revenue
  FROM events
  GROUP BY session_id
)
SELECT
  landing_page,
  SUM(is_visit) AS visits,
  SUM(is_purchase) AS purchases,
  ROUND(SUM(session_revenue), 2) AS sales
FROM sessions
GROUP BY landing_page
ORDER BY visits DESC;