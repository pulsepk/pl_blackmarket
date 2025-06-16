let data = {};
let cart = {};

const cartPanel = document.getElementById("cartPanel");
const cartContent = document.getElementById("cartContent");


const cartTotal = document.getElementById("cartTotal");
const cartButton = document.getElementById("cartToggleButton");
const buyButton = document.getElementById("buyButton");
const itemsContainer = document.getElementById("itemsContainer");
const tabsContainer = document.getElementById("categoryTabs");

function renderCategoryTabs() {
  tabsContainer.innerHTML = "";
  tabsContainer.classList.add("text-white");

  Object.keys(data).forEach((category, index) => {
    const tab = document.createElement("button");
    tab.className = `category-tab ${index === 0 ? 'active-tab' : ''}`;
    tab.dataset.category = category;
    tab.innerHTML = `<p>${category}</p>`;
    tabsContainer.appendChild(tab);
  });

  tabsContainer.querySelectorAll(".category-tab").forEach(tab => {
    tab.addEventListener("click", () => {
      tabsContainer.querySelectorAll(".category-tab").forEach(t => t.classList.remove("active-tab"));
      tab.classList.add("active-tab");
      renderItems(tab.dataset.category);
    });
  });
}

function renderItems(category) {
  itemsContainer.innerHTML = "";

  data[category].forEach((item, index) => {
    const isOutOfStock = item.stock === 0;

    const itemDiv = document.createElement("div");
    itemDiv.className = "bg-[#1e1e1e] border border-[#333] text-white p-4 rounded-xl shadow hover:shadow-lg transition duration-300";
    itemDiv.innerHTML = `
      <div class="flex flex-col justify-between h-full">
        <div class="flex-grow">
          <img src="${item.icon}" alt="${item.name}" class="w-16 h-16 object-contain mb-2 mx-auto" />
          <div class="font-bold text-lg text-center">${item.label}</div>
          <div class="text-sm text-gray-400 text-center mb-2">Price: ${item.price}</div>
          <div class="text-sm text-gray-500 text-center mb-4">Stock: ${item.stock}</div>
        </div>
        <button class="add-to-cart mt-auto bg-gradient-to-r from-[#ff416c] to-[#ff4b2b] hover:from-[#ff4b2b] hover:to-[#ff416c] text-white font-bold py-2 px-4 rounded-xl transition-transform duration-300 hover:scale-105 shadow-md w-full"
          data-index="${index}" ${isOutOfStock ? "disabled style='opacity:0.5; cursor:not-allowed'" : ""}>
          ${isOutOfStock ? "Out of Stock" : "Add to Cart"}
        </button>
      </div>

    `;

    itemDiv.querySelector(".add-to-cart")?.addEventListener("click", () => addToCart(item));
    itemsContainer.appendChild(itemDiv);
  });
}

function addToCart(item) {
  if (item.stock === 0) return;

  if (!cart[item.name]) {
    cart[item.name] = { ...item, quantity: 1 };
  } else if (cart[item.name].quantity < item.stock) {
    cart[item.name].quantity++;
  }

  updateCartPanel();
}

function updateCartPanel() {
  cartContent.innerHTML = "";

  const items = Object.values(cart);
  if (items.length === 0) {
    cartContent.innerHTML = `<p class="text-sm text-gray-400">Cart is currently empty.</p>`;
    cartTotal.textContent = "$0.00";
    return;
  }

  let total = 0;

  items.forEach(item => {
    const quantity = item.quantity;
    const unitPrice = parseFloat(item.price.replace(/[^0-9.]/g, ''));
    total += quantity * unitPrice;

    const row = document.createElement("div");
    row.className = "flex items-center justify-between";
    row.innerHTML = `
      <img src="${item.icon}" class="w-12 h-12 object-contain rounded mr-2" />
      <div class="flex-1 mx-2">
        <div class="font-bold">${item.label}</div>
        <input type="number" min="1" max="${item.stock}" value="${quantity}" class="w-16 bg-[#2b1f1f] text-white p-1 rounded text-center text-sm mt-1 quantity-input" data-name="${item.name}" />
      </div>
      <div class="text-sm font-semibold text-white ml-2">$${(unitPrice * quantity).toFixed(2)}</div>
    `;
    cartContent.appendChild(row);
  });

  cartTotal.textContent = `$${total.toFixed(2)}`;

  cartContent.querySelectorAll(".quantity-input").forEach(input => {
    input.addEventListener("input", (e) => {
      const name = e.target.dataset.name;
      let value = parseInt(e.target.value);
      const max = parseInt(e.target.max);

      if (isNaN(value) || value < 1) value = 1;
      if (value > max) value = max;

      cart[name].quantity = value;
      e.target.value = value;
      updateCartPanel();
    });
  });
}

buyButton?.addEventListener("click", () => {
  if (Object.keys(cart).length === 0) return;

  const totalAmount = parseFloat(cartTotal.textContent.replace(/[^0-9.]/g, ""));

  fetch(`https://${GetParentResourceName()}/buyItems`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ cart, total: totalAmount })
  })
    .then(res => res.json())
    .then(response => {
      if (response.status === 'ok') {
        cart = {};
        updateCartPanel();
        document.getElementById("ui").style.display = "none";
        fetch(`https://${GetParentResourceName()}/hideFrame`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: "{}"
        });
      }
    });
});

cartButton.addEventListener("click", () => {
  cartPanel.classList.toggle("hidden");
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    document.getElementById("ui").style.display = "none";
    cart = {};
    updateCartPanel();

    fetch(`https://${GetParentResourceName()}/hideFrame`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: "{}"
    });
  }
});

window.addEventListener("message", (event) => {
  const msg = event.data;
  if (msg.action === "showUI") {
    data = msg.products;
    document.getElementById("ui").style.display = "block";
    renderCategoryTabs();
    renderItems(Object.keys(data)[0]);
  }
});
