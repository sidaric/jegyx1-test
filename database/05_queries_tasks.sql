-- 05_queries_tasks.sql
-- Required MySQL queries (tagolt output)

SELECT '1) Sikeres tranzakciók (2026-01-01 - 2026-02-28) fizetési mód szerint' AS section;

SELECT
  tfm.payment_method,
  COUNT(DISTINCT t.id) AS successful_transactions_count,
  SUM(tfm.amount_gross) AS paid_gross_sum
FROM tranzakciok t
JOIN tranzakcio_fizetesi_modok tfm
  ON tfm.tranzakcio_id = t.id
WHERE t.status = 'sikeres'
  AND t.created_at >= '2026-01-01'
  AND t.created_at <  '2026-03-01'
GROUP BY tfm.payment_method
ORDER BY successful_transactions_count DESC;

SELECT '' AS spacer;


SELECT '2) Események kihasználtsága (%)' AS section;

SELECT
  e.id,
  e.title,
  e.capacity,
  SUM(CASE WHEN j.status='eladott' THEN 1 ELSE 0 END) AS sold_count,
  ROUND(
    SUM(CASE WHEN j.status='eladott' THEN 1 ELSE 0 END) / e.capacity * 100,
    2
  ) AS utilization_percent
FROM esemenyek e
JOIN jegyek j ON j.esemeny_id = e.id
GROUP BY e.id, e.title, e.capacity
ORDER BY utilization_percent DESC;

SELECT '' AS spacer;


SELECT '3) Napi eladások és bruttó bevétel (2026-01-01-től)' AS section;

SELECT
  DATE(t.created_at) AS nap,
  COUNT(DISTINCT t.id) AS tranzakcio_db,
  SUM(t.total_gross) AS brutto_bevetel
FROM tranzakciok t
WHERE t.status='sikeres'
  AND t.created_at >= '2026-01-01'
GROUP BY DATE(t.created_at)
ORDER BY nap ASC;

SELECT '' AS spacer;


SELECT '4) Top 3 esemény (eladott jegyek száma alapján)' AS section;

SELECT
  e.id,
  e.title,
  COUNT(*) AS sold_tickets
FROM esemenyek e
JOIN jegyek j ON j.esemeny_id = e.id
WHERE j.status='eladott'
GROUP BY e.id, e.title
ORDER BY sold_tickets DESC
LIMIT 3;
