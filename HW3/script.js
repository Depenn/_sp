/**
 * JavaPeaks - Phase 4: Final Polish, Search, & Empty States
 */

// Global state
let mountainData = [];
let map;
let markerLayer;

async function init() {
    try {
        const response = await fetch('gunung.json');
        if (!response.ok) throw new Error('Data failed to load');
        
        mountainData = await response.json();
        
        initMap();
        setupEventListeners();
        
        // Initial render
        renderCards(mountainData);
        updateMarkers(mountainData);

    } catch (error) {
        showErrorMessage();
    }
}

function initMap() {
    map = L.map('map').setView([-7.5, 110.0], 7);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap'
    }).addTo(map);
    markerLayer = L.layerGroup().addTo(map);
}

function setupEventListeners() {
    const searchInput = document.getElementById('search-input');
    const regionFilter = document.getElementById('filter-region');
    const difficultyFilter = document.getElementById('filter-difficulty');
    const resetBtn = document.getElementById('reset-filters');

    const triggerFilter = () => {
        applyFilters(
            searchInput.value.toLowerCase(),
            regionFilter.value,
            difficultyFilter.value
        );
    };

    // Real-time search and filter listeners
    searchInput.addEventListener('input', triggerFilter);
    regionFilter.addEventListener('change', triggerFilter);
    difficultyFilter.addEventListener('change', triggerFilter);

    // Reset logic
    resetBtn.addEventListener('click', () => {
        searchInput.value = '';
        regionFilter.value = 'All';
        difficultyFilter.value = 'All';
        applyFilters('', 'All', 'All');
    });

    // Modal behavior
    const modal = document.getElementById('detail-modal');
    const closeModalElements = [
        document.getElementById('close-modal'),
        document.getElementById('close-modal-bottom'),
        modal // Backdrop
    ];

    closeModalElements.forEach(el => {
        if (!el) return;
        el.addEventListener('click', (e) => {
            if (e.target !== el && el === modal) return;
            modal.classList.add('opacity-0');
            modal.firstElementChild.classList.add('scale-95');
            setTimeout(() => modal.classList.add('hidden'), 300);
        });
    });
}

/**
 * Cumulative filtering for Search, Region, and Difficulty
 */
function applyFilters(query, region, difficulty) {
    const filtered = mountainData.filter(m => {
        const matchSearch = m.nama.toLowerCase().includes(query);
        const matchRegion = region === 'All' || m.wilayah === region;
        const matchDifficulty = difficulty === 'All' || m.kesulitan === difficulty;
        return matchSearch && matchRegion && matchDifficulty;
    });

    renderCards(filtered);
    updateMarkers(filtered);
}

function renderCards(data) {
    const container = document.getElementById('gunung-container');
    if (!container) return;
    
    container.innerHTML = '';

    if (data.length === 0) {
        container.innerHTML = `
            <div class="col-span-full text-center py-24 bg-white rounded-2xl border-2 border-dashed border-slate-200">
                <div class="bg-slate-50 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg class="w-10 h-10 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 9.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                </div>
                <h3 class="text-xl font-bold text-slate-700">Maaf, gunung tidak ditemukan</h3>
                <p class="text-slate-500 mt-2">Coba sesuaikan kata kunci atau filter yang kamu gunakan.</p>
            </div>
        `;
        return;
    }

    data.forEach((mountain) => {
        const card = document.createElement('div');
        // Removed 'opacity-0 translate-y-4' and transitionDelay
        card.className = 'bg-white rounded-xl shadow-md overflow-hidden hover:shadow-2xl hover:-translate-y-1 transition-all duration-300 border border-slate-100 flex flex-col group';

        const diffColor = {
            'Easy': 'bg-green-100 text-green-700',
            'Medium': 'bg-yellow-100 text-yellow-700',
            'Hard': 'bg-red-100 text-red-700'
        }[mountain.kesulitan] || 'bg-slate-100';

        card.innerHTML = `
            <div class="h-48 overflow-hidden relative">
                <img src="${mountain.image_url}" 
                     alt="${mountain.nama}" 
                     class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700">
                <span class="absolute top-3 right-3 px-3 py-1 rounded-full text-xs font-bold ${diffColor} shadow-sm z-10">
                    ${mountain.kesulitan}
                </span>
            </div>
            <div class="p-5 flex-1 flex flex-col">
                <div class="flex justify-between items-start mb-2">
                    <h3 class="text-xl font-bold text-slate-800">${mountain.nama}</h3>
                    <span class="text-emerald-600 font-bold text-sm">${mountain.ketinggian.toLocaleString()} mdpl</span>
                </div>
                <p class="text-slate-500 text-sm mb-4 line-clamp-2">${mountain.description}</p>
                <div class="mt-auto pt-4 border-t border-slate-50 flex items-center justify-between">
                    <span class="text-xs font-medium text-slate-400 uppercase tracking-wider">${mountain.wilayah}</span>
                    <button onclick="openModal(${mountain.id})" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold transition-all shadow-md active:scale-95 text-sm">
                        Detail
                    </button>
                </div>
            </div>
        `;
        container.appendChild(card);
    });
}

window.openModal = function(id) {
    const mountain = mountainData.find(m => m.id === id);
    if (!mountain) return;

    const modal = document.getElementById('detail-modal');
    
    document.getElementById('modal-image').src = mountain.image_url;
    document.getElementById('modal-title').textContent = mountain.nama;

    document.getElementById('modal-region').textContent = mountain.wilayah;
    document.getElementById('modal-height').textContent = `${mountain.ketinggian.toLocaleString()} mdpl`;
    document.getElementById('modal-description').textContent = mountain.description;
    document.getElementById('modal-cost').textContent = `Rp ${mountain.estimasi_biaya.toLocaleString()}`;

    const pathsList = document.getElementById('modal-paths');
    pathsList.innerHTML = '';
    const paths = mountain.jalur_populer || ["Jalur Utama Basecamp", "Jalur Alternatif"];
    paths.forEach(path => {
        const li = document.createElement('li');
        li.textContent = path;
        pathsList.appendChild(li);
    });

    const waMsg = encodeURIComponent(`Halo, saya ingin bertanya tentang pendakian gunung ${mountain.nama}.`);
    document.getElementById('modal-wa-btn').href = `https://wa.me/${mountain.basecamp_wa}?text=${waMsg}`;

    modal.classList.remove('hidden');
    setTimeout(() => {
        modal.classList.remove('opacity-0');
        modal.firstElementChild.classList.remove('scale-95');
    }, 10);
};

function updateMarkers(data) {
    markerLayer.clearLayers();
    data.forEach(m => {
        if (m.koordinat) {
            const marker = L.marker(m.koordinat);
            marker.bindPopup(`
                <div class="text-center p-1">
                    <h4 class="font-bold border-b mb-1">${m.nama}</h4>
                    <p class="text-emerald-600 font-bold">${m.ketinggian} mdpl</p>
                </div>
            `);
            markerLayer.addLayer(marker);
        }
    });

    if (data.length > 0) {
        const group = new L.featureGroup(markerLayer.getLayers());
        map.fitBounds(group.getBounds().pad(0.2));
    } else {
        map.setView([-7.5, 110.0], 7);
    }
}

function showErrorMessage() {
    const container = document.getElementById('gunung-container');
    if (container) {
        container.innerHTML = `
            <div class="col-span-full text-center py-20 bg-red-50 text-red-600 rounded-xl border border-red-100">
                <p class="font-bold text-lg">Error!</p>
                <p>Gagal memuat data gunung. Silakan cek file gunung.json atau koneksi kamu.</p>
            </div>
        `;
    }
}

document.addEventListener('DOMContentLoaded', init);
