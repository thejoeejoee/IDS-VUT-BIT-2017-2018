SELECT
  "note",
  "payment_method",
  "first_name",
  "last_name"
FROM "order"
  JOIN "user" ON "user"."id" = "order"."user_id"
WHERE length("user"."last_name") > 3;

-- kterou pastelku ktery doddavalel , pastelky dodavatel
SELECT
  c."type",
  s."name"

FROM "crayon" c
  JOIN "product" p ON p."id" = c."product_id"
  JOIN "supplier" s ON s."id" = p."supplier_id";

--EASY
-- ke kazdemu hodnoceni jmeno pruduktu, uzitvatele + znamku co dal
SELECT
  r."mark",
  p."name",
  u."last_name"

FROM "rating" r
  JOIN "product" p ON r."product_id" = p."id"
  JOIN "user" u ON r."user_id" = u."id";

-- ke kazdemu hodnoceni ke znamkce cenu produktu + email dodavatele
SELECT
  r."mark",
  r2."description",
  p."name",
  s."email",
  p."price"

FROM "rating" r
  JOIN "user" u ON r."user_id" = u."id"
  JOIN "product" p ON r."product_id" = p."id"
  JOIN "rating" r2 ON u."id" = r2."user_id"
  JOIN "product" p ON r."product_id" = p."id"
  JOIN "supplier" s ON p."supplier_id" = s."id";

-- vsechny objednavky, ktery posilame do PSC zacinajici 77
SELECT
  o."postcode"

FROM "order" o

WHERE TO_CHAR (o."postcode") LIKE '77%';

--vsechny produkty, jejichz dodatel ma email na seznamu && 1000kc az 2000kc
SELECT
  p."price",
  s."name",
  s."email"

FROM "product" p
  JOIN "supplier" s ON p."supplier_id" = s."id"
  JOIN "product" p2 ON s."id" = p2."price"

WHERE s."email" LIKE '%@seznam.cz' AND p."price" BETWEEN 1000 AND 2000;

--ADVANC
-- prumerna gramaz skicaku
SELECT AVG("weight") FROM "sketch";

-- ke kazde objednavce, tolik radku kolik ma v sobe produktu + pocet produktu (navazanych)
-- (kazdy produkt kazde objednavky, kolikrat tam je)
SELECT
  o."id",
  o2."quantity",
  p."name"

FROM "order" o
  JOIN "order_item" o2 ON o."id" = o2."order_id"
  JOIN "order" o3 ON o2."order_id" = o3."id"
  JOIN "product" p ON o2."product_id" = p."id"

ORDER BY "order_id";

-- ke kazde objednavce pocet polozek
SELECT
  SUM (o2."quantity"),
  o."id",
  COUNT(o2."order_id"),
  LISTAGG(o."payment_method", ',') WITHIN GROUP (ORDER BY o."id")

FROM "order" o
  INNER JOIN "order_item" o2 ON o."id" = o2."order_id"

GROUP BY o."id";

-- ke kazdemu skicaku prumer znamek
SELECT
  AVG(r."mark")

FROM "sketch" s
  INNER JOIN "product" p ON s."product_id" = p."id"
  INNER JOIN "rating" r ON p."id" = r."product_id"

GROUP BY p."id";

-- nejlevnejsi produkt, jehoz dodavatel je na gmailu
SELECT p."name"

FROM "product" p
  JOIN "supplier" s ON p."supplier_id" = s."id"
WHERE "email" LIKE '%@gmail.com' AND p."price" = MIN(p."price");
