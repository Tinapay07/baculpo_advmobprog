# baculpo_advmoprog

## Lab Activity 3: Discussion

The cart feature follows the project’s model–service–screen pattern. `Cart` and
`CartProduct` map the JSON response from DummyJSON into typed Dart objects.
`CartService` isolates HTTP work from the interface: it gets one user’s first
cart through `/carts/user/{userId}`, gets an individual cart through
`/carts/{cartId}`, and sends a selected product id and quantity through
`POST /carts/add`. `CartScreen` uses the service in a `FutureBuilder` to render
the user’s cart. When a cart item is tapped, it requests the complete product
record and opens the same `ProductDetailsScreen` used by the shop, keeping
product presentation in one place.

The navigation design keeps Shop, Cart, and Profile in the bottom bar, while
Chat is a floating action button. The chat button is hidden on `CartScreen` to
keep the cart interface focused. The Add to cart button passes the current
product id to the cart service. DummyJSON simulates this POST response instead
of persisting it on the server, so refreshing the fetched user cart returns the
API’s original sample data. `getCartById` uses `/carts/{cartId}` when the app
already knows a particular cart identifier and needs that one cart directly.
