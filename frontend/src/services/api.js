import { CENTRO_MORELIA } from "../utils/geo.js";

const API_BASE = "http://localhost/ruta_segura/api";

function normalizarPunto(punto, index, prefix) {
    const lat = Number(punto.lat ?? punto.latitud);
    const lng = Number(punto.lng ?? punto.lon ?? punto.longitud);

    return {
    id: `${prefix}-${punto.id ?? index + 1}-${punto.orden ?? index + 1}`,
    nombre: punto.nombre ?? `Punto ${index + 1}`,
    lat,
    lng,
    orden: Number(punto.orden ?? index + 1),
    tipo: punto.tipo ?? "parada",
    };
}

function normalizarRuta(ruta, index) {
    const id = Number(ruta.id ?? index + 1);

    const paradas = (Array.isArray(ruta.paradas) ? ruta.paradas : [])
    .map((p, idx) => normalizarPunto(p, idx, `parada-${id}`))
    .filter((p) => Number.isFinite(p.lat) && Number.isFinite(p.lng))
    .sort((a, b) => a.orden - b.orden);

    const trazoRaw = Array.isArray(ruta.trazo) && ruta.trazo.length > 0
    ? ruta.trazo
    : paradas;

    const trazo = trazoRaw
    .map((t, idx) => normalizarPunto(t, idx, `trazo-${id}`))
    .filter((t) => Number.isFinite(t.lat) && Number.isFinite(t.lng))
    .sort((a, b) => a.orden - b.orden);

    return {
    id,
    nombre: ruta.nombre ?? `Ruta ${id}`,
    color: ruta.color || "#38bdf8",
    ocupacion: ruta.ocupacion ?? null,
    destino: ruta.destino ?? (paradas.length ? paradas[paradas.length - 1].nombre : "Destino"),
    paradas,
    trazo,
    };
}

export function obtenerUbicacionActual(fallback = CENTRO_MORELIA) {
    return new Promise((resolve) => {
    if (!navigator.geolocation) {
        resolve({ lat: fallback[0], lng: fallback[1], esRespaldo: true });
        return;
    }

    navigator.geolocation.getCurrentPosition(
        (pos) => {
        resolve({
            lat: pos.coords.latitude,
            lng: pos.coords.longitude,
            esRespaldo: false,
        });
        },
        () => {
        resolve({ lat: fallback[0], lng: fallback[1], esRespaldo: true });
        },
        { timeout: 4000, maximumAge: 10000 }
    );
    });
}

export async function fetchRutas() {
    const res = await fetch(`${API_BASE}/rutas.php`);
    if (!res.ok) throw new Error("Error al cargar rutas desde el backend");

    const json = await res.json();
    if (json && json.success === false) {
    throw new Error(json.error || "El backend reportó un error al obtener rutas");
    }

    const listaRutas = Array.isArray(json?.data)
    ? json.data
    : Array.isArray(json)
    ? json
    : [];

    return listaRutas.map(normalizarRuta);
}

export async function fetchUnidades() {
    const res = await fetch(`${API_BASE}/unidades.php`);
    if (!res.ok) throw new Error("Error al cargar unidades desde el backend");

    const json = await res.json();
    const listaUnidades = Array.isArray(json?.data)
    ? json.data
    : Array.isArray(json)
    ? json
    : [];

    return listaUnidades.map((u, idx) => ({
    ...u,
    id: Number(u.id ?? idx + 1),
    ruta_id: Number(u.ruta_id),
    progreso: Number(u.progreso ?? 0),
    lat: u.lat !== undefined && u.lat !== null ? Number(u.lat) : undefined,
    lng:
        u.lng !== undefined && u.lng !== null
        ? Number(u.lng)
        : u.lon !== undefined && u.lon !== null
        ? Number(u.lon)
        : u.longitud !== undefined && u.longitud !== null
        ? Number(u.longitud)
        : undefined,
    estado: u.estado || "en_movimiento",
    }));
}

export async function enviarReporte(payload) {
    const res = await fetch(`${API_BASE}/reporte.php`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
    });

    const data = await res.json().catch(() => ({}));
    if (!res.ok || data?.success === false) {
    throw new Error(data.error || "No se pudo guardar el reporte");
    }
    return data;
}