let data  = {};
let cart  = {};
let activeCategory = null;

const cartPanel      = document.getElementById("cartPanel");
const cartContent    = document.getElementById("cartContent");
const cartTotal      = document.getElementById("cartTotal");
const cartButton     = document.getElementById("cartToggleButton");
const cartBadge      = document.getElementById("cartBadge");
const buyButton      = document.getElementById("buyButton");
const itemsContainer = document.getElementById("itemsContainer");
const tabsContainer  = document.getElementById("categoryTabs");
const searchInput    = document.getElementById("searchInput");
const tabsSection    = document.getElementById("tabsSection");
const searchHeader   = document.getElementById("searchHeader");
const searchTerm     = document.getElementById("searchTerm");
const searchCount    = document.getElementById("searchCount");

// ── Category tabs ─────────────────────────────────────────────────────────────

function renderCategoryTabs() {
  tabsContainer.innerHTML = "";
  tabsContainer.classList.add("text-white");

  Object.keys(data).forEach((category, index) => {
    const tab = document.createElement("button");
    tab.className = `category-tab ${index === 0 ? "active-tab" : ""}`;
    tab.dataset.category = category;
    tab.innerHTML = `<p>${category}</p>`;
    if (index === 0) activeCategory = category;
    tabsContainer.appendChild(tab);
  });

  tabsContainer.querySelectorAll(".category-tab").forEach(tab => {
    tab.addEventListener("click", () => {
      tabsContainer.querySelectorAll(".category-tab").forEach(t => t.classList.remove("active-tab"));
      tab.classList.add("active-tab");
      activeCategory = tab.dataset.category;
      // Switching tabs clears any active search
      searchInput.value = "";
      showNormalView();
    });
  });
}

// ── Item rendering ────────────────────────────────────────────────────────────

function renderItems(category) {
  itemsContainer.innerHTML = "";
  const items = data[category] ?? [];

  if (items.length === 0) {
    itemsContainer.innerHTML = `<div class="col-span-full text-center text-gray-400 py-10 text-sm">No items available</div>`;
    return;
  }

  items.forEach(item => buildItemCard(item, null));
}

function renderSearchResults(query) {
  const results = [];
  Object.entries(data).forEach(([category, items]) => {
    items.forEach(item => {
      if (
        item.label.toLowerCase().includes(query) ||
        item.name.toLowerCase().includes(query)
      ) {
        results.push({ ...item, _category: category });
      }
    });
  });

  searchTerm.textContent  = query;
  searchCount.textContent = `${results.length} result${results.length !== 1 ? "s" : ""}`;
  itemsContainer.innerHTML = "";

  if (results.length === 0) {
    itemsContainer.innerHTML = `<div class="col-span-full text-center text-gray-400 py-10 text-sm">No items match your search</div>`;
    return;
  }

  results.forEach(item => buildItemCard(item, item._category));
}

function buildItemCard(item, categoryLabel) {
  const isOutOfStock = item.stock === 0;
  const card = document.createElement("div");
  card.className = "relative bg-[#1e1e1e] border border-[#333] text-white p-4 rounded-xl shadow hover:shadow-lg transition duration-300";

  card.innerHTML = `
    ${categoryLabel ? `<span class="absolute top-2 left-2 text-xs bg-[#382929] text-[#b89d9d] px-2 py-0.5 rounded-full leading-none">${categoryLabel}</span>` : ""}
    <div class="flex flex-col justify-between h-full ${categoryLabel ? "pt-5" : ""}">
      <div class="flex-grow">
        <img src="${item.icon}" alt="${item.name}" class="w-16 h-16 object-contain mb-2 mx-auto" />
        <div class="font-bold text-lg text-center">${item.label}</div>
        <div class="text-sm text-gray-400 text-center mb-2">Price: ${item.price}</div>
        <div class="text-sm text-gray-500 text-center mb-4">Stock: ${item.stock}</div>
      </div>
      <button class="add-to-cart mt-auto bg-gradient-to-r from-[#ff416c] to-[#ff4b2b] hover:from-[#ff4b2b] hover:to-[#ff416c] text-white font-bold py-2 px-4 rounded-xl transition-transform duration-300 hover:scale-105 shadow-md w-full"
        ${isOutOfStock ? "disabled style='opacity:0.5;cursor:not-allowed'" : ""}>
        ${isOutOfStock ? "Out of Stock" : "Add to Cart"}
      </button>
    </div>
  `;

  card.querySelector(".add-to-cart")?.addEventListener("click", () => addToCart(item));
  itemsContainer.appendChild(card);
}

// ── Search logic ──────────────────────────────────────────────────────────────

function showNormalView() {
  tabsSection.classList.remove("hidden");
  searchHeader.classList.add("hidden");
  renderItems(activeCategory);
}

function showSearchView(query) {
  tabsSection.classList.add("hidden");
  searchHeader.classList.remove("hidden");
  renderSearchResults(query);
}

searchInput.addEventListener("input", () => {
  const q = searchInput.value.trim().toLowerCase();
  if (q === "") {
    showNormalView();
  } else {
    showSearchView(q);
  }
});

// ── Cart ──────────────────────────────────────────────────────────────────────

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

  const items      = Object.values(cart);
  const totalItems = items.reduce((sum, i) => sum + i.quantity, 0);

  // Badge
  if (totalItems > 0) {
    cartBadge.textContent = totalItems;
    cartBadge.classList.remove("hidden");
  } else {
    cartBadge.classList.add("hidden");
  }

  if (items.length === 0) {
    cartContent.innerHTML = `<p class="text-sm text-gray-400">Cart is currently empty.</p>`;
    cartTotal.textContent = "$0.00";
    return;
  }

  let total = 0;
  items.forEach(item => {
    const quantity  = item.quantity;
    const unitPrice = parseFloat(item.price.replace(/[^0-9.]/g, ""));
    total += quantity * unitPrice;

    const row = document.createElement("div");
    row.className = "flex items-center justify-between";
    row.innerHTML = `
      <img src="${item.icon}" class="w-12 h-12 object-contain rounded mr-2" />
      <div class="flex-1 mx-2">
        <div class="font-bold text-sm">${item.label}</div>
        <input
          type="number" min="1" max="${item.stock}" value="${quantity}"
          class="w-16 bg-[#2b1f1f] text-white p-1 rounded text-center text-sm mt-1 quantity-input"
          data-name="${item.name}"
        />
      </div>
      <div class="text-sm font-semibold text-white ml-2">$${(unitPrice * quantity).toFixed(2)}</div>
    `;
    cartContent.appendChild(row);
  });

  cartTotal.textContent = `$${total.toFixed(2)}`;

  cartContent.querySelectorAll(".quantity-input").forEach(input => {
    input.addEventListener("input", e => {
      const name = e.target.dataset.name;
      let   val  = parseInt(e.target.value);
      const max  = parseInt(e.target.max);
      if (isNaN(val) || val < 1) val = 1;
      if (val > max) val = max;
      cart[name].quantity = val;
      e.target.value = val;
      updateCartPanel();
    });
  });
}

// ── Buy ───────────────────────────────────────────────────────────────────────

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
      if (response.status === "ok") {
        cart = {};
        updateCartPanel();
        closeUI();
      }
    });
});

function closeUI() {
  document.getElementById("ui").style.display = "none";
  fetch(`https://${GetParentResourceName()}/hideFrame`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: "{}"
  });
}

// ── Misc events ───────────────────────────────────────────────────────────────

cartButton.addEventListener("click", () => cartPanel.classList.toggle("hidden"));

document.addEventListener("keydown", event => {
  if (event.key === "Escape") {
    cart = {};
    updateCartPanel();
    closeUI();
  }
});

window.addEventListener("message", event => {
  const msg = event.data;
  if (msg.action !== "showUI") return;

  data = msg.products;
  cart = {};
  searchInput.value = "";

  document.getElementById("ui").style.display = "block";
  cartPanel.classList.add("hidden");
  updateCartPanel();
  renderCategoryTabs();
  showNormalView();
});
