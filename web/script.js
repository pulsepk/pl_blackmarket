const data = {
    "Weapons": [
      { name: "Silenced Pistol", price: "$800",stock:50, icon: "assets/WEAPON_ASSAULTRIFLE.png" },
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
      { name: "Luxury Watch", price: "$3000",stock:50, icon: "⌚" }
    ]
  };

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

    function renderItems(category) {
      itemsContainer.innerHTML = "";
      data[category].forEach(item => {
        const itemDiv = document.createElement("div");
        itemDiv.className = "bg-[#1e1e1e] border border-[#333] text-white p-4 rounded-xl shadow hover:shadow-lg transition duration-300";
        itemDiv.innerHTML = `
          <div>
            <img src="${item.icon}" alt="${item.name}" class="w-16 h-16 object-contain mb-2 mx-auto" />
            <div class="font-bold text-lg">${item.name}</div>
            <div class="text-sm text-gray-400 mb-4">${item.price}</div>
            <div class="text-sm text-gray-400 mb-4">${item.stock}</div>
          </div>
          <button class="bg-gradient-to-r from-[#ff416c] to-[#ff4b2b] hover:from-[#ff4b2b] hover:to-[#ff416c] text-white font-bold py-2 px-4 rounded-xl transition-transform duration-300 hover:scale-105 shadow-md">
            Add to Cart
          </button>

        `;
        itemsContainer.appendChild(itemDiv);
      });
    }

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


  const cartButton = document.getElementById("cartToggleButton");
const cartPanel = document.getElementById("cartPanel");

cartButton.addEventListener("click", () => {
  cartPanel.classList.toggle("hidden");
});
