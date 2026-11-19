import React, { useEffect } from "react";
import { MapContainer, TileLayer, Polyline, Marker, Circle, CircleMarker, Popup, useMap } from "react-leaflet";
import L from "leaflet";
import { CENTRO_MORELIA } from "../utils/geo.js";

const busIcon = L.divIcon({
    html: `<div style="font-size:36px;filter:drop-shadow(0 0 8px yellow);">🚌</div>`,
    className: "",
    iconSize: [40, 40],
});

const paradaIcon = L.divIcon({
    html: "🚏",
    className: "stop-icon",
    iconSize: [35, 35],
});

const userIcon = L.divIcon({
    html: "📍",
    className: "user-icon",
    iconSize: [24, 24],
});

const COLOR_REPORTE = {
    unidad_llena: "#ef4444",
    unidad_pasando: "#22c55e",
    incidencia_accesibilidad: "#f97316",
};

const ETIQUETA_REPORTE = {
    unidad_llena: "Unidad Llena",
    unidad_pasando: "Unidad Pasando",
    incidencia_accesibilidad: "Incidencia / Accesibilidad",
};

function AjustarVistaRutas({ rutas }) {
    const map = useMap();

    useEffect(() => {
    const todasLasCoords = rutas.flatMap((r) => {
        const fuente = Array.isArray(r.trazo) && r.trazo.length > 0 ? r.trazo : r.paradas || [];
        return fuente.map((p) => [p.lat, p.lng]);
    });

    if (todasLasCoords.length > 0) {
        map.fitBounds(todasLasCoords, { padding: [40, 40] });
    }
    }, [rutas, map]);

    return null;
}

export default function MapaRutas({ rutas = [], unidades = [], reportes = [], ubicacionUsuario = null }) {
    return (
    <MapContainer center={CENTRO_MORELIA} zoom={13} className="map-container">
        <TileLayer
        url="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution="&copy; <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors"
        />

        <AjustarVistaRutas rutas={rutas} />

        {rutas.map((ruta) => {
        const fuenteTrazo = Array.isArray(ruta.trazo) && ruta.trazo.length > 0 ? ruta.trazo : ruta.paradas || [];
        const posicionesTrazo = fuenteTrazo.map((p) => [p.lat, p.lng]);
        const paradasVisibles = (ruta.paradas || []).filter((p) => p.tipo !== "intermedio");

        return (
            <React.Fragment key={ruta.id}>
            <Polyline
                positions={posicionesTrazo}
                pathOptions={{ color: ruta.color || "#38bdf8", weight: 8, opacity: 0.9 }}
            />
            {paradasVisibles.map((parada) => (
                <Marker key={parada.id} position={[parada.lat, parada.lng]} icon={paradaIcon}>
                <Popup>{parada.nombre}</Popup>
                </Marker>
            ))}
            </React.Fragment>
        );
        })}

        {unidades.map((unidad) => {
        const ruta = rutas.find((r) => r.id === unidad.ruta_id);
        const esSaturada = (unidad.ocupacion ?? 50) >= 80;
        return (
            <Marker key={unidad.id} position={[unidad.lat, unidad.lng]} icon={busIcon}>
            <Popup>
                <h3>
                {esSaturada ? "🔴" : "🔵"} {ruta?.nombre || unidad.codigo}
                </h3>
                <p>Unidad: {unidad.codigo}</p>
                <p>Ocupación: {unidad.ocupacion ?? 50}%</p>
                <p>Destino: {unidad.destino || ruta?.destino || "Centro"}</p>
                <p>Estado: {unidad.estado === "detenida" ? "Detenida" : esSaturada ? "Saturada" : "Disponible"}</p>
            </Popup>
            </Marker>
        );
        })}

        {ubicacionUsuario && (
        <Marker position={[ubicacionUsuario.lat, ubicacionUsuario.lng]} icon={userIcon}>
            <Popup>Tu ubicación</Popup>
        </Marker>
        )}

        {reportes.map((rep) => {
        const color = COLOR_REPORTE[rep.tipo] || "#38bdf8";
        return (
            <React.Fragment key={rep.id}>
            {rep.tipo === "incidencia_accesibilidad" && (
                <Circle
                center={[rep.lat, rep.lng]}
                radius={120}
                pathOptions={{ color: "#f97316", fillColor: "#f97316", fillOpacity: 0.3 }}
                />
            )}
            <CircleMarker
                center={[rep.lat, rep.lng]}
                radius={10}
                pathOptions={{ color, fillColor: color, fillOpacity: 1 }}
            >
                <Popup>
                <b>{ETIQUETA_REPORTE[rep.tipo] || rep.tipo}</b>
                </Popup>
            </CircleMarker>
            </React.Fragment>
        );
        })}
    </MapContainer>
    );
}