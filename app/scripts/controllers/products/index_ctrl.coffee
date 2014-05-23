app = angular.module("myApp")

class IndexCtrl extends BaseCtrl

  @register app, "products.IndexCtrl"
  @inject "$scope", "alerts", "Products"

  initialize: ->
    @$scope.products = []
    @$scope.totalServerItems = 0
    @$scope.selectedProducts = []

    @$scope.pagingOptions =
      pageSizes: [10, 20, 50, 100]
      pageSize: 10
      currentPage: 1

    fetchProducts = =>
      params = _.pick(@$scope.pagingOptions, "currentPage", "pageSize")
      params.sortField = @$scope.sortInfo.fields[0]
      params.sortDirection = @$scope.sortInfo.directions[0]

      promise = @Products.query(params).$promise
      promise.then (data) =>
        @$scope.products = data.rows
        @$scope.totalServerItems = data.total

    @$scope.sortInfo =
      fields: ["id"]
      directions: ["asc"]

    nameCellTpl = """
      <div>
        <a ui-sref="products.show.info({id: row.getProperty('id')})">
          <i class="fa fa-search"></i>
          {{row.getProperty('name')}}
        </a>
      </div>
    """

    gridColumnDefs = [
      { field: "id",          displayName: "#", width: "auto" }
      {
        field: "name"
        displayName: "Name"
        resizable: true
        cellTemplate: nameCellTpl
      }
      { field: "price",       displayName: "Price", width: "120px", resizable: false }
      { field: "description", displayName: "Description" }
      { field: "createdAt",   displayName: "Created At" }
    ]

    @$scope.gridOptions =
      plugins: [
        new ngGridFlexibleHeightPlugin()
      ]

      data: "products"
      columnDefs: gridColumnDefs
      totalServerItems: "totalServerItems"
      enableColumnResize: true
      enablePaging: true
      pagingOptions: @$scope.pagingOptions
      sortInfo: @$scope.sortInfo
      useExternalSorting: true
      showFooter: true
      primaryKey: "id"

      multiSelect: true
      selectWithCheckboxOnly: true
      showSelectionCheckbox: true
      selectedItems: @$scope.selectedProducts

      rowHeight: 32
      headerRowHeight: 45
      footerRowHeight: 55

    loadGrid = (newVal, oldVal) ->
      fetchProducts() unless angular.equals(newVal, oldVal)

    @$scope.$watch "pagingOptions.currentPage", loadGrid, true
    @$scope.$watch "pagingOptions.pageSize", loadGrid, true
    @$scope.$watch "sortInfo.fields", loadGrid, true
    @$scope.$watch "sortInfo.directions", loadGrid, true

    fetchProducts()

  clearSelection: ->
    @$scope.selectedProducts.splice(0, @$scope.selectedProducts.length)
    @$scope.gridOptions.selectAll(false)

  deleteProduct: (product) ->
    promise = product.$delete()
    promise.then =>
      index = @products.indexOf(product)
      @products.splice(index, 1) if index isnt -1

      @alerts.info "Product was deleted"
