

const data = {
    "Weapons": [
      { name: "Silenced Pistol", price: "$800",stock:0, icon: "assets/WEAPON_ASSAULTRIFLE.png" },
      { name: "Assault Rifle", price: "$2500",stock:50, icon: "assets/WEAPON_ASSAULTRIFLE.png" },
      { name: "Assault Rifle", price: "$2500",stock:50, icon: "assets/WEAPON_ASSAULTRIFLE.png" },
      { name: "Assault Rifle", price: "$2500",stock:50, icon: "assets/WEAPON_ASSAULTRIFLE.png" },

    ],
    "Ammo": [
      { name: "9mm Rounds", price: "$50",stock:50, icon: "💥" },
      { name: "5.56mm NATO", price: "$80",stock:50, icon: "💥" }
    ],
    "Hacking Devices": [
      { name: "Signal Jammer", price: "$600",stock:50, icon: "🧰" }
    ],
    "Illegal Documents": [
      { name: "Fake Passport", price: "$1500",stock:50, icon: "🪪" }
    ],
    "Drugs": [
      { name: "Cocaine Pack", price: "$5000",stock:50, icon: "💊" }
    ],
    "Smuggled Goods": [
      { name: "Luxury Watch", price: "$3000",stock:50, icon: "⌚" },
      { name: "Luxury Watch 2", price: "$3000",stock:50, icon: "⌚" },
      { name: "Luxury Watch 3", price: "$3000",stock:50, icon: "⌚" }
    ]
  };
  const cartPanel = document.getElementById("cartPanel");
const cartContent = document.createElement("div");
cartPanel.appendChild(cartContent);
let cart = {};

function renderItems(category) {
  itemsContainer.innerHTML = "";

  data[category].forEach((item, index) => {
    const itemDiv = document.createElement("div");
    itemDiv.className =
      "bg-[#1e1e1e] border border-[#333] text-white p-4 rounded-xl shadow hover:shadow-lg transition duration-300";

    const isOutOfStock = item.stock === 0;

    itemDiv.innerHTML = `
      <div>
        <img src="${item.icon}" alt="${item.name}" class="w-16 h-16 object-contain mb-2 mx-auto" />
        <div class="font-bold text-lg text-center">${item.name}</div>
        <div class="text-sm text-gray-400 text-center mb-2">Price: ${item.price}</div>
        <div class="text-sm text-gray-500 text-center mb-4">Stock: ${item.stock}</div>
        <button class="add-to-cart bg-gradient-to-r from-[#ff416c] to-[#ff4b2b] hover:from-[#ff4b2b] hover:to-[#ff416c] text-white font-bold py-2 px-4 rounded-xl transition-transform duration-300 hover:scale-105 shadow-md w-full"
          data-index="${index}" ${isOutOfStock ? "disabled style='opacity:0.5; cursor:not-allowed'" : ""}>
          ${isOutOfStock ? "Out of Stock" : "Add to Cart"}
        </button>
      </div>
    `;

    const button = itemDiv.querySelector(".add-to-cart");
    button?.addEventListener("click", () => addToCart(item));
    itemsContainer.appendChild(itemDiv);
  });
}

  document.addEventListener("DOMContentLoaded", () => {
    const tabsContainer = document.getElementById("categoryTabs");
    const itemsContainer = document.getElementById("itemsContainer");
    tabsContainer.classList.add("text-white");

    // Build category tabs once
    Object.keys(data).forEach((category, index) => {
      const tab = document.createElement("button");
      tab.className = `category-tab ${index === 0 ? 'active-tab' : ''}`;
      tab.dataset.category = category;
      tab.innerHTML = `<p>${category}</p>`;
      tabsContainer.appendChild(tab);
    });


    // Initial render
    const firstCategory = Object.keys(data)[0];
    renderItems(firstCategory);

    // Handle tab clicks
    tabsContainer.querySelectorAll(".category-tab").forEach(tab => {
      tab.addEventListener("click", () => {
        tabsContainer.querySelectorAll(".category-tab").forEach(t => t.classList.remove("active-tab"));
        tab.classList.add("active-tab");
        renderItems(tab.dataset.category);
      });
    });
    const buyButton = document.getElementById("buyButton");
  if (buyButton) {
    buyButton.addEventListener("click", () => {
      if (Object.keys(cart).length === 0) return;
      alert("Purchase successful!");
      for (const key in cart) {
        delete cart[key];
      }
      updateCartPanel();
    });
  }
  });

function addToCart(item) {
  if (item.stock === 0) return;

  if (!cart[item.name]) {
    cart[item.name] = {
      ...item,
      quantity: 1
    };
  } else if (cart[item.name].quantity < item.stock) {
    cart[item.name].quantity++;
  }

  updateCartPanel();
}

function updateCartPanel() {
  const cartContent = document.getElementById("cartContent");
  const cartTotal = document.getElementById("cartTotal");

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
        <div class="font-bold">${item.name}</div>
        <input type="number" min="1" max="${item.stock}" value="${quantity}" class="w-16 bg-[#2b1f1f] text-white p-1 rounded text-center text-sm mt-1 quantity-input" data-name="${item.name}" />
      </div>
      <div class="text-sm font-semibold text-white ml-2">$${(unitPrice * quantity).toFixed(2)}</div>
    `;

    cartContent.appendChild(row);
  });

  cartTotal.textContent = `$${total.toFixed(2)}`;

  const inputs = cartContent.querySelectorAll(".quantity-input");
  inputs.forEach(input => {
    input.addEventListener("input", e => {
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



const cartButton = document.getElementById("cartToggleButton");
const cartPanelButton = document.getElementById("cartPanel");

cartButton.addEventListener("click", () => {
  cartPanelButton.classList.toggle("hidden");
}); 


window.addEventListener('message', function(event) {
  if (event.data.action === "showUI") {
    document.getElementById("ui").style.display = "block";
    requestAnimationFrame(() => {
      renderCategories(event.data.products);
    });
  }
});

document.addEventListener("keydown", function(event) {
if (event.key === "Escape") {
      clearCartItems()
      document.getElementById("ui").style.display = "none";
      axios.post(`https://${GetParentResourceName()}/hideFrame`, {})
      .then(function (response) { 
      })
      .catch(function (error) {
      });
  }
});