let categories = []
let items = []
let cart = []
let filteredItems = []

// Elementos DOM
const tabletContainer = document.getElementById("tablet-container")
const closeBtn = document.getElementById("close-btn")
const searchInput = document.getElementById("search-input")
const categoryFilters = document.getElementById("category-filters")
const itemsGrid = document.getElementById("items-grid")
const cartItems = document.getElementById("cart-items")
const cartTotal = document.getElementById("cart-total")
const placeOrderBtn = document.getElementById("place-order-btn")

// Função para obter o nome do recurso pai
function GetParentResourceName() {
  // Implementação da função aqui
  return "parent-resource-name" // Exemplo de retorno
}

// Event Listeners
closeBtn.addEventListener("click", closeTablet)
searchInput.addEventListener("input", filterItems)
placeOrderBtn.addEventListener("click", placeOrder)

// Escutar mensagens do cliente
window.addEventListener("message", (event) => {
  const data = event.data

  switch (data.action) {
    case "openTablet":
      categories = data.categories
      items = data.items
      openTablet()
      break
    case "closeTablet":
      closeTablet()
      break
  }
})

function openTablet() {
  tabletContainer.classList.remove("hidden")
  setupCategories()
  filteredItems = [...items]
  renderItems()
  updateCart()
}

function closeTablet() {
  tabletContainer.classList.add("hidden")
  cart = []

  // Enviar callback para o cliente
  fetch(`https://${GetParentResourceName()}/closeTablet`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({}),
  })
}

function setupCategories() {
  categoryFilters.innerHTML = `
        <button class="category-btn active" data-category="all">
            <i class="fas fa-th"></i> Todos
        </button>
    `

  categories.forEach((category) => {
    const btn = document.createElement("button")
    btn.className = "category-btn"
    btn.dataset.category = category.name
    btn.innerHTML = `<i class="${category.icon}"></i> ${category.label}`
    btn.addEventListener("click", () => filterByCategory(category.name))
    categoryFilters.appendChild(btn)
  })

  // Event listener para botão "Todos"
  document.querySelector('[data-category="all"]').addEventListener("click", () => filterByCategory("all"))
}

function filterByCategory(categoryName) {
  // Atualizar botões ativos
  document.querySelectorAll(".category-btn").forEach((btn) => {
    btn.classList.remove("active")
  })
  document.querySelector(`[data-category="${categoryName}"]`).classList.add("active")

  // Filtrar itens
  if (categoryName === "all") {
    filteredItems = [...items]
  } else {
    filteredItems = items.filter((item) => item.category === categoryName)
  }

  renderItems()
}

function filterItems() {
  const searchTerm = searchInput.value.toLowerCase()
  const activeCategory = document.querySelector(".category-btn.active").dataset.category

  const baseItems = activeCategory === "all" ? items : items.filter((item) => item.category === activeCategory)

  if (searchTerm) {
    filteredItems = baseItems.filter(
      (item) => item.label.toLowerCase().includes(searchTerm) || item.description.toLowerCase().includes(searchTerm),
    )
  } else {
    filteredItems = baseItems
  }

  renderItems()
}

function renderItems() {
  itemsGrid.innerHTML = ""

  filteredItems.forEach((item) => {
    const itemCard = document.createElement("div")
    itemCard.className = "item-card"
    itemCard.innerHTML = `
            <div class="item-image">
                <i class="fas fa-box"></i>
            </div>
            <div class="item-name">${item.label}</div>
            <div class="item-price">R$ ${item.price.toLocaleString("pt-BR")}</div>
        `

    itemCard.addEventListener("click", () => addToCart(item))
    itemsGrid.appendChild(itemCard)
  })
}

function addToCart(item) {
  const existingItem = cart.find((cartItem) => cartItem.name === item.name)

  if (existingItem) {
    existingItem.quantity += 1
  } else {
    cart.push({
      name: item.name,
      label: item.label,
      price: item.price,
      quantity: 1,
    })
  }

  updateCart()
}

function removeFromCart(itemName) {
  cart = cart.filter((item) => item.name !== itemName)
  updateCart()
}

function updateQuantity(itemName, change) {
  const item = cart.find((cartItem) => cartItem.name === itemName)
  if (item) {
    item.quantity += change
    if (item.quantity <= 0) {
      removeFromCart(itemName)
    } else {
      updateCart()
    }
  }
}

function updateCart() {
  if (cart.length === 0) {
    cartItems.innerHTML = '<p class="empty-cart">Carrinho vazio</p>'
    cartTotal.textContent = "R$ 0"
    placeOrderBtn.disabled = true
    return
  }

  let total = 0
  cartItems.innerHTML = ""

  cart.forEach((item) => {
    const itemTotal = item.price * item.quantity
    total += itemTotal

    const cartItem = document.createElement("div")
    cartItem.className = "cart-item"
    cartItem.innerHTML = `
            <div class="cart-item-info">
                <div>${item.label}</div>
                <div style="color: #4CAF50; font-size: 12px;">R$ ${itemTotal.toLocaleString("pt-BR")}</div>
            </div>
            <div class="cart-item-controls">
                <button class="quantity-btn" onclick="updateQuantity('${item.name}', -1)">-</button>
                <span style="color: white; margin: 0 8px;">${item.quantity}</span>
                <button class="quantity-btn" onclick="updateQuantity('${item.name}', 1)">+</button>
            </div>
        `

    cartItems.appendChild(cartItem)
  })

  cartTotal.textContent = `R$ ${total.toLocaleString("pt-BR")}`
  placeOrderBtn.disabled = false
}

function placeOrder() {
  if (cart.length === 0) return

  const orderData = {
    items: cart,
    timestamp: Date.now(),
  }

  // Enviar pedido para o servidor
  fetch(`https://${GetParentResourceName()}/placeOrder`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(orderData),
  })

  // Limpar carrinho
  cart = []
  updateCart()
}

// Função global para atualizar quantidade (chamada pelos botões)
window.updateQuantity = updateQuantity

// Fechar tablet com ESC
document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    closeTablet()
  }
})
