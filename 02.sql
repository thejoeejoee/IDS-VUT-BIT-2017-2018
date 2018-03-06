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
  "email"         VARCHAR2(64),
  "password_hash" VARCHAR2(128) NOT NULL,
  "first_name"    VARCHAR2(32),
  "last_name"     VARCHAR2(32),
  "phone"         VARCHAR2(32),
  "street"        VARCHAR2(64),
  "city"          VARCHAR2(64),
  "postcode"      NUMBER
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

  "user_id"        NUMBER           NOT NULL
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
  "product_id"  NUMBER NOT NULL
);

CREATE TABLE "product"
(
  "id"          NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  "name"        VARCHAR2(256),
  "price"       NUMBER NOT NULL,
  "supplier_id" NUMBER NOT NULL
);

CREATE TABLE "crayon"
(
  "product_id" NUMBER NOT NULL,
  "type"       NUMBER,
  "quantity"   NUMBER,
  "length"     NUMBER
);

CREATE TABLE "sketch"
(
  "product_id" NUMBER NOT NULL,
  "weight"     NUMBER,
  "size"       VARCHAR2(16),
  "quantity"   NUMBER
);

CREATE TABLE "supplier"
(
  "id"    NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  "name"  VARCHAR2(64),
  "phone" VARCHAR2(64),
  "email" VARCHAR2(64)
);

-- indexy a cizi klice
CREATE UNIQUE INDEX user_email_uindex
  ON "user" ("email");
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
INSERT INTO "supplier" ("name", "phone", "email") VALUES ('ASUS tech', '852369854', 'sony@email.cz');

INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Dlouhe pastelky', 150, 1);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Kratsi pastelky', 120, 1);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('DELUXE pastelky', 200, 1);

INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (1, 1, 15, 25);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (2, 2, 10, 10);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (3, 1, 10, 15);

INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Pastelky super', 238, 2);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Pastelky dobre', 100, 2);

INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (4, 1, 2, 30);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (5, 2, 4, 18);

INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky velke', 500, 2);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky vetsi', 560, 2);

INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (6, 150, 'XS', 25);
INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (7, 180, 'XL', 35);

INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Pastelky super, made in China', 238 * .2, 3);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Pastelky dobre, made in China', 100 * .2, 3);

INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (8, 1, 30, 12);
INSERT INTO "crayon" ("product_id", "type", "quantity", "length") VALUES (9, 2, 32, 8);

INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky velke, made in China', 500 * .2, 3);
INSERT INTO "product" ("name", "price", "supplier_id") VALUES ('Skicaky vetsi, made in China', 560 * .2, 3);

INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (10, 80, 'S', 50);
INSERT INTO "sketch" ("product_id", "weight", "size", "quantity") VALUES (11, 90, 'L', 45);

INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES ('sony@mail.cz', 'hash_TODO', 'Sony', 'Nguyen', '125745632', 'Macharova', 'Olomouc', 77900);
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES ('joe@email.cz', 'hash_TODO', 'Joe', 'Novak', '741528963', 'Novakova', 'Brno', 77200);
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES ('franta@jozka.cz', 'hash_TODO', 'Frantisek', 'Jemenek', '789523632', 'Bratislavska', 'Prerov', 77800);
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES ('jana.kolarova@kolar.cz', 'hash_TODO', 'Jana', 'Kolarova', '+420585696363', 'nam. Republiky', 'Olomouc', 74802);
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES ('roman.maxmilian@kolar.cz', 'hash_TODO', 'Roman', 'Maxmilian', '+789456123', 'Uzka', 'Nezamyslice', 78411);
INSERT INTO "user" ("email", "password_hash", "first_name", "last_name", "phone", "street", "city", "postcode")
VALUES ('petram@seznam.cz', 'hash_TODO', 'Petra', 'Moudra', '789456123', 'Masarykova', 'Prerov', 78950);


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
VALUES (1, '---', 1, 2);
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


