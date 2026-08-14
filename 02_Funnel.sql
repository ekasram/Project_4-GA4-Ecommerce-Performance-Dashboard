WITH events AS (
  SELECT
    event_name,
    CONCAT(user_pseudo_id, '-',
      (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')
    ) AS session_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)
SELECT
  COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN session_id END) AS session_start,
  COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN session_id END) AS view_item,
  COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN session_id END) AS add_to_cart,
  COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN session_id END) AS begin_checkout,
  COUNT(DISTINCT CASE WHEN event_name = 'add_shipping_info' THEN session_id END) AS add_shipping_info,
  COUNT(DISTINCT CASE WHEN event_name = 'add_payment_info' THEN session_id END) AS add_payment_info,
  COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_id END) AS purchase
FROM events;