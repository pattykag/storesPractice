const cds = require('@sap/cds');
const { Store, Price, Store_Owner, Products } = cds.entities;

module.exports = cds.service.impl (async(srv) => {
    
    // Ejercicio de prueba
    srv.on('updateStore', async(req) => {
        const tienda = {
            ID : req.data.stores.ID,
            nombre : req.data.stores.name,
            fundacion : req.data.stores.foundation           
        }

        try {
            await cds.run(UPDATE(Store).set({name : tienda.nombre}).where({ID:tienda.ID}))
            return("tienda lista");
        } catch (error) {
            console.log(error);
            return("explotus");
        }
    });
    

    // Actualizar lista de precios
    srv.on('updatePrecio', async (req) => {
        const precio = {
            ID : req.data.precio.ID,
            costo : req.data.precio.costo,
            currency : req.data.precio.currency
        }
        try {
            await cds.run(UPDATE(Price).set({costo : precio.costo},{currency : precio.currency}).where({ID:precio.ID}))
            return("Precio listo");
        } catch (error) {
            console.log(error);
            return("explotus");
        }
    });


    // Cuando creo un dueño por url le paso las tiendas para q cree la relación
    srv.after('CREATE','Owner', async (data, req) => {
        /*
        const { ID, name, age } = data;
        console.log(name);
        */

        const owner = {
            ID : data.ID,
            nombre : data.name,
            edad : data.age
        }

        console.log(req._.req.query)
        let { Stores } = req._.req.query;
        
        if (!Stores) {
            console.log("EL dueño no tiene tiendas");
            return;
        }
        
        try {
            let store_ID = Stores.split(",");
            let arregloStoreOwner = [];

            for(let i in store_ID){
                arregloStoreOwner.push({
                    owner_ID: owner.ID,
                    store_ID: store_ID[i]
                }) 
            };

            await INSERT.into(Store_Owner).entries(arregloStoreOwner)
            return `Dueño y tiendas asociados`;
        } catch (error) {
            console.log(error);
            return `Explotus`;
        }
    });
    
    // Control de stock de productos: action q retira cantidades de productos y agrega cantidad, con id y cantidad. Los productos tendrán un min y máximo q disparara alerta al llegar a los mismos.

    srv.on('modificarStock', async (req) => {
        const { product_ID, stock } = req.data;

        const consultarProducto = await cds.run(SELECT('stock', 'stock_min', 'stock_max').one.from(Products).where({ ID: product_ID }));
        let stockTotal = stock + consultarProducto.stock;

        if (stockTotal < consultarProducto.stock_min) {
            console.log(`El total de productos en tu stock es de ${stockTotal}, el mínimo que podías tener era de ${consultarProducto.stock_min}`);
        } else if (stockTotal > consultarProducto.stock_max) {
            console.log(`El total de productos en tu stock es de ${stockTotal}, podías tener un máximo de ${consultarProducto.stock_max}`);
        }

        try {
            await cds.run(UPDATE(Products).with({stock: stockTotal}).where({ ID : product_ID }));
            return `Valor ingresado con éxito`;
            // donde el 1er stock es el nombre del campo de la entidad y el segundo es el nombre del campo que usé en postman
            // await cds.run(UPDATE(Products).with({stock: { '+=': stock }}).where({ book_ID: book}));
        } catch (error) {
            console.log(error);
            return `Explotus`;
        }
    });

});