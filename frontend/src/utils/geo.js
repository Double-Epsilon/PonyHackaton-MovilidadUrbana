export const CENTRO_MORELIA = [19.7008, -101.1844];

/**
 * Calcula la posición [lat, lng] a partir de una lista de puntos [lat, lng]
 * y un progreso normalizado entre 0 y 1.
 */
export function calcularPosicionEnRuta(puntos = [], progreso = 0) {
    if (!Array.isArray(puntos) || puntos.length === 0) {
    return CENTRO_MORELIA;
    }
    if (puntos.length === 1) {
    return puntos[0];
    }

    const p = ((progreso % 1) + 1) % 1;
    const totalSegmentos = puntos.length - 1;
    const posicionExacta = p * totalSegmentos;
    const indice = Math.min(Math.floor(posicionExacta), totalSegmentos - 1);
    const t = posicionExacta - indice;

    const [lat1, lng1] = puntos[indice];
    const [lat2, lng2] = puntos[indice + 1];

  const lat = lat1 + (lat2 - lat1) * t;
  const lng = lng1 + (lng2 - lng1) * t;

    return [Number(lat.toFixed(7)), Number(lng.toFixed(7))];
}

/**
 * Calcula los minutos estimados restantes (ETA) y el nombre de la parada actual
 * según el progreso (0 a 1) de una unidad sobre su ruta.
 */
export function calcularEstadoLlegada(ruta, progreso = 0) {
    if (!ruta || !Array.isArray(ruta.paradas) || ruta.paradas.length === 0) {
    return { etaMin: 5, paradaActual: "En ruta" };
    }

    const totalParadas = ruta.paradas.length;
    const p = ((progreso % 1) + 1) % 1;
    const indiceActual = Math.min(
    Math.floor(p * (totalParadas - 1)),
    totalParadas - 1
    );
    const etaMin = Math.max(1, Math.ceil((1 - p) * totalParadas));

    return {
    etaMin,
    paradaActual: ruta.paradas[indiceActual]?.nombre || "En ruta",
    };
}