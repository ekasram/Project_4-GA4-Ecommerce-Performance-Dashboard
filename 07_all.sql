WITH events AS (
  SELECT
    CONCAT(user_pseudo_id, '-',
      (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')) AS session_id,

    event_timestamp,
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    event_name,

    device.category AS device_category,
    device.language AS device_language,
    device.operating_system AS device_os,

    traffic_source.source AS source,
    traffic_source.medium AS medium,
    traffic_source.name AS campaign,

    REGEXP_EXTRACT(
      (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'),r'https?://[^/]+(/[^?]*)'
    ) AS page_location,

    ecommerce.purchase_revenue_in_usd AS revenue

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)

SELECT
  session_id,
  MIN(event_date) AS event_date,

  ARRAY_AGG(
    IF(event_name = 'page_view', page_location, NULL)IGNORE NULLS
    ORDER BY event_timestamp
    LIMIT 1)
    [SAFE_OFFSET(0)] AS landing_page,

  ANY_VALUE(source) AS source,
  ANY_VALUE(medium) AS medium,
  ANY_VALUE(campaign) AS campaign,

  ANY_VALUE(device_category) AS device_category,
  ANY_VALUE(device_language) AS device_language,
  ANY_VALUE(device_os) AS device_os,

  MAX(CASE WHEN event_name = 'session_start' THEN 1 ELSE 0 END) AS visits,
  MAX(CASE WHEN event_name = 'view_item' THEN 1 ELSE 0 END) AS view_item,
  MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS add_to_cart,
  MAX(CASE WHEN event_name = 'begin_checkout' THEN 1 ELSE 0 END) AS begin_checkout,
  MAX(CASE WHEN event_name = 'add_shipping_info' THEN 1 ELSE 0 END) AS add_shipping_info,
  MAX(CASE WHEN event_name = 'add_payment_info' THEN 1 ELSE 0 END) AS add_payment_info,
  MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase,
  SUM(CASE WHEN event_name = 'purchase' THEN revenue ELSE 0 END) AS revenue

FROM events
GROUP BY session_id;