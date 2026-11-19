import React, { useState } from "react";

const OPCIONES_REPORTE = [
    {
    tipo: "unidad_llena",
    etiqueta: "🚌 Unidad Llena",
    clase: "red",
    },
    {
    tipo: "unidad_pasando",
    etiqueta: "📍 Unidad Pasando Aquí",
    clase: "green",
    },
    {
    tipo: "incidencia_accesibilidad",
    etiqueta: "⚠️ / ♿ Incidencia o Accesibilidad",
    clase: "orange",
    },
];

export default function BotonesReporte({ onCrearReporte }) {
    const [enviando, setEnviando] = useState(false);
    const [confirmacion, setConfirmacion] = useState("");

    const manejarClick = async (opcion) => {
    setEnviando(true);
    setConfirmacion("");
    try {
        const msg = await onCrearReporte(opcion.tipo);
        setConfirmacion(msg || `Reporte "${opcion.etiqueta}" registrado.`);
    } catch (err) {
        setConfirmacion(err.message || "Error al enviar reporte.");
    } finally {
        setEnviando(false);
    }
    };

    return (
    <div>
        <h3>Reportes Ciudadanos</h3>

        {OPCIONES_REPORTE.map((op) => (
        <button
            key={op.tipo}
            type="button"
            className={`btn ${op.clase}`}
            disabled={enviando}
            onClick={() => manejarClick(op)}
        >
            {enviando ? "Enviando..." : op.etiqueta}
        </button>
        ))}

        {confirmacion && <div className="confirm-msg">{confirmacion}</div>}
    </div>
    );
}