import { useEffect, useState } from "react";
import { calcularPosicionEnRuta } from "../utils/geo.js";

function obtenerPuntosRecorrido(ruta) {
    if (!ruta) return [];
    const fuente = Array.isArray(ruta.trazo) && ruta.trazo.length > 0 ? ruta.trazo : ruta.paradas || [];
    return fuente.map((p) => [p.lat, p.lng]);
}

export function useSimulador(unidadesIniciales = [], rutas = [], { paso = 0.02, intervaloMs = 2000 } = {}) {
    const [unidades, setUnidades] = useState([]);

    useEffect(() => {
    if (Array.isArray(unidadesIniciales) && unidadesIniciales.length > 0) {
        const conCoordenadas = unidadesIniciales.map((u, idx) => {
        const ruta = rutas.find((r) => r.id === u.ruta_id);
        const puntos = obtenerPuntosRecorrido(ruta);
        const [latCalc, lngCalc] = calcularPosicionEnRuta(puntos, u.progreso ?? 0);

        return {
            ...u,
            id: u.id ?? idx + 1,
            progreso: u.progreso ?? 0,
            lat: Number.isFinite(u.lat) ? u.lat : latCalc,
            lng: Number.isFinite(u.lng) ? u.lng : lngCalc,
        };
        });
        setUnidades(conCoordenadas);
        return;
    }

    if (Array.isArray(rutas) && rutas.length > 0) {
        const generadas = rutas
        .filter((r) => obtenerPuntosRecorrido(r).length > 0)
        .map((r, idx) => {
            const puntos = obtenerPuntosRecorrido(r);
            return {
            id: `sim-${r.id}`,
            ruta_id: r.id,
            codigo: `Unidad ${r.nombre}`,
            progreso: (idx * 0.25) % 1,
            lat: puntos[0][0],
            lng: puntos[0][1],
            estado: "en_movimiento",
            ocupacion: r.ocupacion ?? 50,
            destino: r.destino,
            };
        });
        setUnidades(generadas);
    }
    }, [unidadesIniciales, rutas]);

    useEffect(() => {
    if (!unidades.length || !rutas.length) return;

    const timer = setInterval(() => {
        setUnidades((prev) =>
        prev.map((unidad) => {
            if (unidad.estado === "detenida") {
            return unidad;
            }

            const nuevoProgreso = Number((((unidad.progreso ?? 0) + paso) % 1).toFixed(4));
            const ruta = rutas.find((r) => r.id === unidad.ruta_id);
            const puntos = obtenerPuntosRecorrido(ruta);
            const [lat, lng] = calcularPosicionEnRuta(puntos, nuevoProgreso);

            return {
            ...unidad,
            progreso: nuevoProgreso,
            lat,
            lng,
            };
        })
        );
    }, intervaloMs);

    return () => clearInterval(timer);
    }, [unidades.length, rutas, paso, intervaloMs]);

    return unidades;
}