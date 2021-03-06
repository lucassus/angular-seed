resources = angular.module("myApp.resources", ["ngResource"])

resources.factory "Products", [
  "$resource", ($resource) ->
    Products = $resource "/api/products/:id.json", id: "@id",
      query: { method: "GET", isArray: true }
      get: { method: "GET" }

    angular.extend Products.prototype,
      # Returns true when the product is persisted (has an id)
      persisted: -> !!@id

      # Returns price with discount
      priceWithDiscount: ->
        return @price unless @hasDiscount()
        return @price * (1 - @discount / 100.0)

      # Returns true when the product has a discount
      hasDiscount: -> @discount? and @discount > 0

    Products
]
