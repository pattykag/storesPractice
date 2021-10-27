using { cuid, managed, sap } from '@sap/cds/common';
namespace stores;


// Types de las entidades
type NameString : String(50);
type Currency : Association to sap.common.Currencies;

// Aspects
aspect precio {
    costo : Decimal(5,2);
    currency : Currency @assert.integrity: false; // @assert.integrity: false; evita el problema al cargar una currency 
}

// entidad de tiendas
entity Store : cuid, managed {
    name : NameString;
    foundation : Integer;
    owners : Association to many Store_Owner on owners.store = $self;
    product : Association to many Store_Product on product.store = $self;
}

// entidad de propietarios
entity Owner : cuid {
    name : NameString;
    age : Integer;
    store : Association to many Store_Owner on store.owner = $self;
}

// entidad de asociación de dueños y tiendas
entity Store_Owner : cuid {
    key owner : Association to Owner;
    key store : Association to Store;
}

// entidad de productos
entity Products : cuid, managed {
    name : NameString;
    description : String(100);
    stock : Integer;
    stock_min : Integer;
    stock_max : Integer;
    store : Association to many Store_Product on store.product = $self;
    precio : Association to Price;
    brand : Association to Brand;
    productsubtype : Association to ProductSubtype;   
}

// entidad de asociación de dueños y tiendas
entity Store_Product : cuid {
    key product : Association to Products;
    key store : Association to Store;
} 

// entidad de precios
entity Price : cuid, precio {
    product : Association to many Products on product.precio = $self;
}

// entidad de marcas
entity Brand : cuid {
    name : NameString;
    product : Association to many Products on product.brand = $self;
}

// entidad tipo de productos
entity ProductType : cuid {
    name : NameString;
    productsubtype : Association to many ProductSubtype on productsubtype.producttype = $self;
}

// entidad subtipo
entity ProductSubtype : cuid {
    product : Association to Products;
    producttype : Association to ProductType;
    name : NameString;
}