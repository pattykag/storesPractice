using {stores as my} from '../db/schema';

service aplicacion {

    entity Store              as select from my.Store;

    entity Owner              as select from my.Owner;

    entity Store_Owner        as
        select from my.Store_Owner {
            *,
            store.name as store_name,
            owner.name as owner_name
        };


    entity Store_Product      as
        select from my.Store_Product {
            *,
            product.name       as product_name,
            store.name         as store_name,
            product.brand.name as brand_name
        };

    entity Price              as select from my.Price;
    entity Brand              as projection on my.Brand;
    entity Products           as projection on my.Products;
    entity ProductType        as projection on my.ProductType;

    entity ProductSubtype     as
        select from my.ProductSubtype {
            *,
            product.name     as product_name,
            producttype.name as producttype_name
        }
        order by
            product_name desc;

    // Vista filtrada por marca
    @cds.redirection.target : true
    entity Vista_de_Productos as
        select from my.Products {
            *,
            brand.name                      as brand_name,
            productsubtype.producttype.name as type_name,
            productsubtype.name             as subtype_name,
            description,
            precio.currency                 as precio_currency,
            precio.costo                    as costo
        }
        where
            brand.name = 'Arcor';

    entity Vista_Precios      as
        select from my.Products {
            ID,
            name,
            brand.name                      as brand_name,
            productsubtype.producttype.name as type_name,
            productsubtype.name             as subtype_name,
            description,
            precio.currency                 as precio_currency,
            precio.costo                    as costo
        }
        where
                precio.costo > 10
            and precio.costo < 200;

    action updateStore(stores : Store) returns String;
    action updatePrecio(precio : Price) returns String;
    action ownerURL(owner : Owner) returns String;
    action modificarStock(product_ID : Products:ID, stock : Products:stock) returns String;
}
