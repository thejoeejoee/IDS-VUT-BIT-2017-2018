-- For new order_items with order=null finds first free order and fill order col with it.
CREATE OR REPLACE TRIGGER order_item_bi__auto_order_generator
  BEFORE INSERT
  ON "order_item"
  FOR EACH ROW
  DECLARE
    v_max_order "order_item"."order"%TYPE;
  BEGIN
    if :new."order" IS NULL -- only if is not set
    then
      -- select maximal order value in order
      select max("order_item"."order")
      into v_max_order
      from "order_item"
      where "order_item"."order_id" = :NEW."order_id";

      :NEW."order" := v_max_order + 1;

    --EXCEPTION
    --WHEN
    end if;
  END;

-- After deleting order_item finds all empty orders and delete them.
CREATE OR REPLACE TRIGGER order_item_ad__empty_order_cleaner
  AFTER DELETE
  ON "order_item"
  BEGIN
    delete "order"
    where "order"."id" NOT IN (
      select "order_id"
      from "order_item"
    );
  END;

-- example for first trigger
insert into "order_item" ("order_id", "product_id", "quantity") values (1, 12, 3);
-- example for second trigger
insert into "order" ("user_id") values (1);
insert into "order_item" ("order_id", "product_id") values (
  (
    select max("id") + 1
    from "order"
  ),
  1
);
delete "order_item"
where "order" = (
  select max("order")
  from "order_item"
  where "order_id" = (
    select max("id") + 1
    from "order"
  )
) AND "order_id" = (select max("id") + 1
                    from "order");


-- procedure for copying order items from source order to target order
create or replace procedure copy_order_items(
  source_order_id IN "order"."id"%TYPE,
  target_order_id IN "order"."id"%TYPE
) IS
  cursor c_order_items_to_copy is
    SELECT *
    FROM "order_item"
    WHERE "order_item"."order_id" = source_order_id
    ORDER BY "order" ASC;

  new_item     c_order_items_to_copy%ROWTYPE;
  target_order "order"%ROWTYPE;

    e_invalid_target_order EXCEPTION;
    e_target_same_as_source EXCEPTION;
  BEGIN
    select *
    into target_order
    from "order"
    where "id" = target_order_id;

    if SQL%NOTFOUND -- cannot copy items to non existing target
    then
      raise e_invalid_target_order;
    end if;

    if source_order_id = target_order_id -- cannot copy items to itself
    then
      raise e_target_same_as_source;
    end if;

    OPEN c_order_items_to_copy;
    LOOP
      FETCH c_order_items_to_copy INTO new_item;
      EXIT WHEN c_order_items_to_copy%NOTFOUND;

      new_item."order_id" := target_order_id;
      new_item."order" := NULL; -- trigger creates new value for "order" col
      insert into "order_item" values new_item;

    END LOOP;

    COMMIT;

    CLOSE c_order_items_to_copy;
    EXCEPTION
    WHEN e_invalid_target_order
    then
      DBMS_OUTPUT.PUT_LINE('Unknown target order: ' || TO_CHAR(target_order_id) || '.');
    WHEN e_target_same_as_source
    then
      DBMS_OUTPUT.PUT_LINE('Target order cannot be same as source order.');
    WHEN OTHERS
    THEN
      DBMS_OUTPUT.PUT_LINE(SQLCODE || SQLERRM);
  end;

begin
  -- copies items from order.id=1 to order.id=2
  copy_order_items(1, 2);
end;

  -- procedure for deleting users without order
create or replace procedure delete_users_without_orders is
  begin
    DELETE "user"
    where "user"."id" NOT IN (
      select "order"."user_id"
      from "order"
    );
  end;

begin
  delete_users_without_orders();
end;
-- select *
-- from user_errors
-- where type = 'TRIGGER';


-- optimizing queries
explain plan for
SELECT
  "supplier"."name",
  count(DISTINCT "user"."id")
FROM "supplier"
  INNER JOIN "product" ON "supplier"."id" = "product"."supplier_id"
  INNER JOIN "order_item" ON "product"."id" = "order_item"."product_id"
  INNER JOIN "order" ON "order_item"."order_id" = "order"."id"
  INNER JOIN "user" ON "order"."user_id" = "user"."id"
WHERE "user"."city" = 'Brno'
GROUP BY "supplier"."name";

select *
from TABLE (DBMS_XPLAN.display);

create index user_city_index
  on "user" ("city");

explain plan for
select
  "supplier"."name",
  count(DISTINCT "user"."id")
from "supplier"
  inner join "product" on "supplier"."id" = "product"."supplier_id"
  inner join "order_item" on "product"."id" = "order_item"."product_id"
  inner join "order" on "order_item"."order_id" = "order"."id"
  inner join "user" on "order"."user_id" = "user"."id"
where "user"."city" = 'Brno'
group by "supplier"."name";

select *
from TABLE (DBMS_XPLAN.display);

-- from xkavan05 connection
grant select on XKAVAN05.USER to XKOLAR71;
grant select on XKAVAN05.ORDER to XKOLAR71;
grant select on XKAVAN05.ORDER_ITEM to XKOLAR71;
grant select on XKAVAN05.PRODUCT to XKOLAR71;

drop materialized view v_users_with_over_average_priced_orders;

-- from xkolar71 connection
create materialized view v_users_with_over_average_priced_orders as
  select u."id" as id
  from XKAVAN05."user" u
  where u."id" IN (
    select o."user_id"
    from XKAVAN05."order" o
      inner join XKAVAN05."order_item" oi on o."id" = oi."order_id"
      inner join XKAVAN05."product" p on p."id" = oi."product_id"
    GROUP BY o."id", o."user_id"
    having SUM(p."price" * oi."quantity") > (

      select AVG(SUM(p."price" * oi."quantity"))
      from XKAVAN05."order" o
        inner join XKAVAN05."order_item" oi on o."id" = oi."order_id"
        inner join XKAVAN05."product" p on p."id" = oi."product_id"
      GROUP BY o."id"
    )
  );
grant select on XKOLAR71.V_USERS_WITH_OVER_AVERAGE_PRICED_ORDERS to XKAVAN05;

-- select from xkavan05 to xkolar71 view
select *
from "user"
where "id" in (
  select id
  from XKOLAR71.V_USERS_WITH_OVER_AVERAGE_PRICED_ORDERS
);
