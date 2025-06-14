const data = {
    "Weapons": [
      { name: "Silenced Pistol", price: "$800", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
      { name: "Assault Rifle", price: "$2500", icon: "🔫" },
    ],
    "Ammo": [
      { name: "9mm Rounds", price: "$50", icon: "💥" },
      { name: "5.56mm NATO", price: "$80", icon: "💥" }
    ],
    "Hacking Devices": [
      { name: "Signal Jammer", price: "$600", icon: "🧰" }
    ],
    "Illegal Documents": [
      { name: "Fake Passport", price: "$1500", icon: "🪪" }
    ],
    "Drugs": [
      { name: "Cocaine Pack", price: "$5000", icon: "💊" }
    ],
    "Smuggled Goods": [
      { name: "Luxury Watch", price: "$3000", icon: "⌚" }
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
            <div class="text-3xl mb-2">${item.icon}</div>
            <div class="font-bold text-lg">${item.name}</div>
            <div class="text-sm text-gray-400 mb-4">${item.price}</div>
          </div>
          <button class="mt-auto bg-gradient-to-r from-[#8e2de2] to-[#4a00e0] hover:from-[#4a00e0] hover:to-[#8e2de2] text-white font-semibold py-2 px-4 rounded-xl transition duration-300 ease-in-out hover:scale-105 shadow-md">
            Buy
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

