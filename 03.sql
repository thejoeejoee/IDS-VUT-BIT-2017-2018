-- IDS - 2. cast projektu - SQL skript pro vytvoreni zakladnich objektu schematu databaze
-- autori: Iva Kavankova, Josef Kolar

DROP TABLE "user" CASCADE CONSTRAINTS;
DROP TABLE "order" CASCADE CONSTRAINTS;
DROP TABLE "rating" CASCADE CONSTRAINTS;
DROP TABLE "crayon" CASCADE CONSTRAINTS;
DROP TABLE "sketch" CASCADE CONSTRAINTS;
DROP TABLE "product" CASCADE CONSTRAINTS;
DROP TABLE "order_item" CASCADE CONSTRAINTS;
DROP TABLE "supplier" CASCADE CONSTRAINTS;

-- cele schema
CREATE TABLE "user"
(
  "id"            NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  "email"         VARCHAR2(320) NOT NULL,
  "password_hash" VARCHAR2(128) NOT NULL,
  "first_name"    VARCHAR2(32),
  "last_name"     VARCHAR2(32),
  "phone"         VARCHAR2(32),
  "street"        VARCHAR2(64),
  "city"          VARCHAR2(64),
  "birth_number"  VARCHAR2(12),
  "postcode"      NUMBER,
  CONSTRAINT postcode_check CHECK ("postcode" > 0 AND "postcode" <= 99999),
  CONSTRAINT birth_number_check CHECK (
    REGEXP_LIKE("birth_number", '[0-9]{2}[0156][0-9][0-3][0-9]/?[0-9]{3,4}') AND
    MOD(CAST(REPLACE("birth_number", '/', '') AS NUMBER), 11) = 0

  ),
  CONSTRAINT user_birth_number_unique UNIQUE ("birth_number"),
  CONSTRAINT user_email_unique UNIQUE ("email")

);

CREATE TABLE "order"
(
  "id"             NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  "payment_method" NUMBER DEFAULT 1 NOT NULL,
  "street"         VARCHAR2(64),
  "street_number"  VARCHAR2(16),
  "city"           VARCHAR2(64),
  "postcode"       NUMBER,
  "note"           VARCHAR2(256),
  "state"          NUMBER,

  "user_id"        NUMBER           NOT NULL,

  CONSTRAINT order_payment_method_enum_check CHECK ("payment_method" IN (0, 1, 2, 3)),
  CONSTRAINT order_state_enum_check CHECK ("payment_method" IN (0, 1, 2, 3, 4, 5))
);

CREATE TABLE "order_item"
(
  "order_id"   NUMBER           NOT NULL,
  "order"      NUMBER           NOT NULL,
  "product_id" NUMBER           NOT NULL,
  "quantity"   NUMBER DEFAULT 1 NOT NULL
);


CREATE TABLE "rating"
(
  "id"          NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  "mark"        NUMBER NOT NULL,
  "description" NCLOB,
  "user_id"     NUMBER NOT NULL,
  "product_id"  NUMBER NOT NULL,
  CONSTRAINT rating_mark_check CHECK ("mark" > 0 AND "mark" <= 5)
);

CREATE TABLE "product"
(
  "id"          NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  "name"        VARCHAR2(256),
  "price"       NUMBER NOT NULL,
  "supplier_id" NUMBER NOT NULL,

  CONSTRAINT product_price_check CHECK ("price" >= 0)
);

CREATE TABLE "crayon"
(
  "product_id" NUMBER PRIMARY KEY,
  "type"       NUMBER,
  "quantity"   NUMBER,
  "length"     NUMBER,
  CONSTRAINT crayon_quantity_check CHECK ("quantity" > 0),
  CONSTRAINT crayon_length_check CHECK ("length" > 0),
  CONSTRAINT crayon_type_check CHECK ("type" IN (1, 2, 3, 4, 5))
);

CREATE TABLE "sketch"
(
  "product_id" NUMBER PRIMARY KEY,
  "weight"     NUMBER,
  "size"       VARCHAR2(16),
  "quantity"   NUMBER,
  CONSTRAINT sketch_quantity_check CHECK ("quantity" > 0),
  CONSTRAINT sketch_weight_check CHECK ("weight" > 0)
);

CREATE TABLE "supplier"
(
  "id"    NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  "name"  VARCHAR2(64),
  "phone" VARCHAR2(64),
  "email" VARCHAR2(320),

  CONSTRAINT supplier_email_unique UNIQUE ("email")
);

-- indexy a cizi klice
ALTER TABLE "order_item"
  ADD CONSTRAINT order_item_pk PRIMARY KEY ("order_id", "order");
ALTER TABLE "order_item"
  ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");
ALTER TABLE "order_item"
  ADD FOREIGN KEY ("product_id") REFERENCES "product" ("id");
ALTER TABLE "order"
  ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");
ALTER TABLE "crayon"
  ADD FOREIGN KEY ("product_id") REFERENCES "product" ("id");
ALTER TABLE "sketch"
  ADD FOREIGN KEY ("product_id") REFERENCES "product" ("id");
ALTER TABLE "product"
  ADD FOREIGN KEY ("supplier_id") REFERENCES "supplier" ("id");
ALTER TABLE "rating"
  ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");
ALTER TABLE "rating"
  ADD FOREIGN KEY ("product_id") REFERENCES "product" ("id");

-- data pro dotazy
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('OLC Systems', '+420123456789', 'mail@olc.cz');
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('Sony corp', '+236874521369', 'sony@email.cz');
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('ASUS tech', '852369854', 'asus@asus.com');
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('Papirnictvi Litovel', '777256958', 'papir@litovel.cz');
INSERT INTO "supplier" ("name", "phone", "email")
VALUES ('Potreby pro malire Prerov', '733256999', 'malirskepotreby@prerov.cz');
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('TESCO', '570248596', 'order@tesco.com');
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('Svet pastelek', '720185469', 'pastelky@pastelky.cz');
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('Mame vse', '752869485', 'vse@vsechno.cz');
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('Obchudek', '608598632', 'obchudek@seznam.cz');
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('Penny Market', '607589632', 'dodatel@penny.cz');
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('Dutosvarcova korporace', '123456789', 'dutosvarc@disney.cz');
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('OBI', '777456825', 'karel@obi.com');

INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Dlouhe pastelky', 150, 1);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Kratsi pastelky', 120, 1);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Modre pastelky', 200, 2);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Zelene pastelky', 202, 2);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Cervene pastelky', 205, 3);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Cerne pastelky', 208, 3);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Zlute pastelky', 220, 4);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Ruzove pastelky', 207, 4);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Fialove pastelky', 200, 5);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('DELUXE pastelky', 205, 5);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Pastelky super', 238, 6);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Pastelky dobre', 100, 6);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Tluste pastelky', 152, 7);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Tenke pastelky', 170, 7);

INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (1, 1, 15, 25);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (2, 2, 10, 10);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (3, 1, 10, 15);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (4, 1, 2, 30);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (5, 2, 4, 18);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (6, 1, 32, 12);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (7, 2, 18, 8);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (8, 1, 5, 15);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (9, 2, 1, 21);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (10, 1, 25, 22);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (11, 2, 36, 23);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (12, 1, 42, 32);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (13, 1, 19, 42);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (14, 2, 30, 28);

INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky velke', 500, 2);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky vetsi', 560, 1);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky barevne', 580, 2);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky modre', 565, 2);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky zlute', 560, 3);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky zelene', 570, 2);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky ruzove', 600, 4);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky fialove', 555, 3);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky bile', 575, 2);

INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (15, 150, 'XS', 25);
INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (16, 180, 'XL', 35);
INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (17, 155, 'M', 50);
INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (18, 170, 'XL', 5);
INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (19, 181, 'S', 28);
INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (20, 190, 'S', 32);
INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (21, 180, 'XL', 42);

INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Pastelky super, made in China', 238 * .2, 3);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Pastelky dobre, made in China', 100 * .2, 3);

INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (22, 1, 30, 12);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (23, 2, 32, 8);

INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky velke, made in China', 500 * .2, 3);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky vetsi, made in China', 560 * .2, 3);

INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (24, 80, 'S', 50);
INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (25, 90, 'L', 45);

-- used bcrypt with 4 iterations, random passwords
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode", "birth_number")
VALUES ('sony@mail.cz', '$2a$04$KGnvHtOiSxaeIdwUhxQNqu7QAjKU8.h939qezQdQPQaO2FPsOVJVm', 'Sony', 'Nguyen', '125745632',
        'Macharova', 'Olomouc', 77900, '990310/7313');
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode", "birth_number")
VALUES ('joe@email.cz', '$2a$04$kl8SshrJ5ZDOY6BOqMo3aetzUHMlq8R2nviN.bY33N32gk504kn8K', 'Joe', 'Novak', '741528963',
        'Novakova', 'Brno', 77200, '7010137464');
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES ('franta@jozka.cz', '$2a$04$Kacb/3HfcjBVBMfPwuQivusx3nXg1Xax0HpoaI5.wqmojRMn6pKDu', 'Frantisek', 'Jemenek',
        '789523632', 'Bratislavska', 'Prerov', 77800);
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode", "birth_number")
VALUES ('jana.kolarova@kolar.cz', '$2a$04$FkfGBxae7Ic2VBcrm9VI6eZRqTYC3CIXbI7/.EQPLOqmX4jfaD.oK', 'Jana', 'Kolarova',
        '+420585696363', 'nam. Republiky', 'Olomouc', 74802, '7209027056');
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES
  ('roman.maxmilian@kolar.cz', '$2a$04$9Co7Bf7ohM.fX4GBO9VCkeiuBgW5TRGz3v3pRbJsjZR0CN/LKZiqS', 'Roman', 'Maxmilian',
   '+789456123', 'Uzka', 'Nezamyslice', 78411);
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES
  ('petram@seznam.cz', '$2a$04$CtIBCZmTE1IS0PlZ8AE2c.Y3rcRUWyXh5WW55B6YcEqNtjeI/2fHC', 'Petra', 'Moudra', '789456123',
   'Masarykova', 'Prerov', 78950);
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode", "birth_number")
VALUES
  ('karel@seznam.cz', '$2a$04$1WhGfU335qo7hP0pchy4k.DyswQqYxJ/qVepJov.CiqpF3GzDvTD2', 'Karel', 'Karlovic', '589624859',
   'Modra', 'Brno', 7604, '9954143254');
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES
  ('pavel.kohout@abc.cz', '$2a$04$ffqhhOdWrHqT61OBt0iFZuyvFNqW4JHlRbYoOY8PGpkDpevChqXMq', 'Pavel', 'Kohout',
   '577486526',
   'Hroudova', 'Breclav', 78236);
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES
  ('hermelina@novakova.cz', '$2a$04$jf78RFIBF7tsaIFcphvwA.HcsqMXnuYph9nMQSSC7MBu3Umj52h8q', 'Hermelina', 'Novakova',
   '586987569',
   'Husitska', 'Brno', 73005);
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES
  ('stanislav@svarak.cz', '$2a$04$xnu67lhka1UGsATE/idR7uWSCrXzakrgB4DsVxxR/85o7ea8hUN4a', 'Stanislav', 'Svarak',
   '148579625',
   'Sumavska', 'Brno', 74002);


INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (1, 'Poradne zabalit prosim', 1, 1);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (1, 1, 2, 10);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (1, 2, 1, 11);

INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (1, 'Dekuji', 1, 1);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (2, 1, 2, 5);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (2, 2, 10, 8);

INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (1, 'zadne pripominky', 1, 1);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (3, 1, 2, 1);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (3, 2, 2, 4);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (3, 3, 2, 6);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (3, 5, 2, 8);


INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (1, 'zadny koment', 1, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (4, 1, 8, 3);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (4, 2, 6, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (4, 3, 1, 7);

INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (1, '---', 3, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (5, 1, 2, 5);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (5, 2, 10, 8);

INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (2, 'dekuji mnohokrat', 1, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (6, 1, 15, 9);

INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (2, 'balit prosim samostatne', 1, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (7, 1, 10, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (7, 2, 7, 3);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (7, 3, 3, 4);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (7, 4, 10, 11);

INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (2, 'co nejdrive prosim', 2, 3);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (8, 1, 9, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (8, 2, 4, 3);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (8, 3, 3, 6);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (8, 4, 10, 11);

INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (2, 'nevolat, psat sms, dekuji', 2, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (9, 1, 10, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (9, 2, 7, 8);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (9, 3, 9, 4);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (9, 4, 10, 10);

INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (2, 'nerozbit prosim', 1, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (10, 1, 10, 1);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (10, 2, 8, 3);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (10, 3, 3, 4);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (10, 4, 7, 11);

INSERT INTO "order" ("payment_method", "note", "state", "user_id")
VALUES (2, 'specha, mam to pro manzelku', 4, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (11, 1, 4, 2);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (11, 2, 7, 3);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (11, 3, 4, 4);
INSERT INTO "order_item" ("order_id", "order", "quantity", "product_id") VALUES (11, 4, 10, 8);

INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (2, 'prumer', 1, 5);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (2, 'nuda', 2, 7);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (4, 'k nicemu', 3, 8);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (3, 'normalni kvalita', 4, 8);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (3, 'co sem mam napsat?', 5, 9);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (4, 'podprumerne', 6, 6);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (1, 'fakt dobre', 7, 3);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (2, 'standardni', 8, 2);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (3, 'nic moc', 9, 3);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (5, 'je mi to k nicemu', 4, 3);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (4, 'podivna vec', 2, 4);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (4, 'moc krátké', 5, 5);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (1, 'super pristup', 6, 8);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (1, 'dobrá kvalita', 3, 9);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (2, 'lepsi nez z Ciny', 2, 10);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (2, 'bez komentare', 1, 15);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (2, 'to se neda moc komentovat', 4, 13);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (3, 'vyhovuje', 10, 17);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (5, 'strasny produkt', 10, 18);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (4, 'nikdy vice', 10, 22);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (1, 'jsem spokojen', 8, 2);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (4, 'takova normalka', 5, 15);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (5, 'lepsi nez od konkurence', 5, 10);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (2, 'prumer', 4, 11);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (1, 'vyborne', 4, 12);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (2, 'male chybky', 7, 13);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (5, 'totalni hruza', 8, 14);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (4, 'lepsi vyhodit', 9, 15);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (1, 'funguji dobre', 6, 17);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (2, 'standardni', 3, 19);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id")
VALUES (5, 'neda se nic napsat, totalni propadak!', 2, 1);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (3, 'fakt super nakup!', 1, 1);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (1, 'nejlepsi produkt!', 2, 2);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id")
VALUES (5, 'totalni katastrofa, nedoporucuji!', 3, 3);
INSERT INTO "rating" ("mark", "description", "user_id", "product_id") VALUES (2, 'celkem dobry produkt', 4, 4);

-- 1.dotaz - kterou pastelku dodava ktery dodavatel
SELECT
  p."name",
  s."name"

FROM "crayon" c
  JOIN "product" p ON p."id" = c."product_id"
  JOIN "supplier" s ON s."id" = p."supplier_id";

-- 2.dotaz - ke kazdemu hodnoceni nazev produktu a jeho znamku
SELECT
  p."name",
  r."description",
  r."mark"

FROM "rating" r
  JOIN "product" p ON r."product_id" = p."id"
  JOIN "user" u ON r."user_id" = u."id";

-- 3.dotaz - ke kazdemu hodnoceni pastelky vypsat dodavelete, delku, nazev a znamku jakou dostala
SELECT
  u."last_name",
  p."name",
  c."length",
  r."description",
  r."mark"

FROM  "crayon" c
  INNER JOIN "product" p ON p."id" = c."product_id"
  INNER JOIN "rating" r ON r."product_id" = p."id"
  INNER JOIN "user" u ON u."id" = r."id";

--- 4.dotaz - ke kazdemu skicaku prumer znamek a pocet hodnoceni
SELECT
  p."name",
  AVG(r."mark") prumer_znamek,
  COUNT(r."product_id") pocet_hodnoceni

FROM "sketch" s
  INNER JOIN "product" p ON s."product_id" = p."id"
  INNER JOIN "rating" r ON p."id" = r."product_id"

GROUP BY p."id", p."name";

-- 5.dotaz - ke kazde objednavce pocet ruznych polozek
SELECT
  o."id" id_objednavky,
  COUNT(o2."order_id") pocet_polozek

FROM "order" o
  INNER JOIN "order_item" o2 ON o."id" = o2."order_id"

GROUP BY o."id";

-- 6.dotaz - vsechni dodavatele, kteri maji ke svemu produktu alespon 1 hodnoceni a zaroven maji mezeru ve jmene
SELECT
  s."name"

FROM "supplier" s

WHERE s."name" LIKE '% %' AND EXISTS(
    SELECT 1 FROM "rating"
      INNER JOIN "product" p ON s."id" = p."supplier_id"
);

-- 7.dotaz - vsechny uzivatele kteri si obejdnali alespon 1 nadprumerne drahou objednavku
select
  "first_name",
  "last_name"
from "user"
where "user"."id" IN (
  select "order"."user_id"
  from "order"
    inner join "order_item" on "order"."id" = "order_item"."order_id"
    inner join "product" on "product"."id" = "order_item"."product_id"
  GROUP BY "order"."id", "order"."user_id"
  having SUM("price" * "quantity") > (

    select AVG(SUM("price" * "quantity"))
    from "order"
      inner join "order_item" on "order"."id" = "order_item"."order_id"
      inner join "product" on "product"."id" = "order_item"."product_id"
    GROUP BY "order"."id"
  )
);
