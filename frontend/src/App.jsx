import React, { useEffect, useState } from "react";
import MapaRutas from "./components/MapaRutas.jsx";
import BotonesReporte from "./components/BotonesReporte.jsx";
import { useSimulador } from "./hooks/useSimulador.js";
import { enviarReporte, fetchRutas, fetchUnidades, obtenerUbicacionActual } from "./services/api.js";
import { calcularEstadoLlegada } from "./utils/geo.js";

export default function App() {
  const [rutas, setRutas] = useState([]);
  const [unidadesBase, setUnidadesBase] = useState([]);
  const [rutaSeleccionadaId, setRutaSeleccionadaId] = useState(null);
  const [reportes, setReportes] = useState([]);
  const [ubicacionUsuario, setUbicacionUsuario] = useState(null);
  const [errorCarga, setErrorCarga] = useState("");
  const [menuOculto, setMenuOculto] = useState(false);

  const unidadesEnMovimiento = useSimulador(unidadesBase, rutas);

  useEffect(() => {
    obtenerUbicacionActual().then((loc) => setUbicacionUsuario(loc));

    fetchRutas()
      .then((data) => {
        setRutas(data);
        if (data.length > 0) {
          setRutaSeleccionadaId(data[0].id);
        }
      })
      .catch((err) => {
        setErrorCarga(err.message || "No se pudieron cargar las rutas.");
      });

    fetchUnidades()
      .then((data) => {
        setUnidadesBase(data);
      })
      .catch(() => {});
  }, []);

  const handleCrearReporte = async (tipo) => {
    const loc = await obtenerUbicacionActual();
    setUbicacionUsuario(loc);

    const payload = {
      ruta_id: rutaSeleccionadaId ?? rutas[0]?.id ?? 1,
      tipo,
      lat: loc.lat,
      lng: loc.lng,
    };

    await enviarReporte(payload);

    setReportes((prev) => [...prev, { id: Date.now(), ...payload }]);

    return loc.esRespaldo
      ? "Reporte guardado en BD (usando centro del mapa como respaldo)."
      : "Reporte guardado en BD en tu ubicación actual.";
  };

  const totalReportes = reportes.length;
  const totalIncidencias = reportes.filter(
    (r) =>
      r.tipo === "incidencia" ||
      r.tipo === "accesibilidad" ||
      r.tipo === "incidencia_accesibilidad"
  ).length;

  const llegadasPorRuta = rutas.map((ruta) => {
    const unidad = unidadesEnMovimiento.find((u) => u.ruta_id === ruta.id);
    const { etaMin, paradaActual } = calcularEstadoLlegada(ruta, unidad?.progreso ?? 0);
    return {
      ruta,
      unidad,
      etaMin,
      paradaActual,
    };
  });

  const masCercana = [...llegadasPorRuta].sort((a, b) => a.etaMin - b.etaMin)[0];

  return (
    <div>
      <header className="header">
        <div className="header-left">
          <button
            type="button"
            className="menu-btn"
            aria-label="Alternar menú lateral"
            onClick={() => setMenuOculto((prev) => !prev)}
          >
            ☰
          </button>
          <h2>🚌 Ruta Segura</h2>
        </div>
        <span>Morelia, Michoacán</span>
      </header>

      <aside className={`sidebar ${menuOculto ? "oculto" : ""}`}>
        {rutas.length > 0 && (
          <div className="card">
            <h4>🛣️ Ruta activa</h4>
            <select
              value={rutaSeleccionadaId ?? ""}
              onChange={(e) => setRutaSeleccionadaId(Number(e.target.value))}
              style={{ width: "100%", padding: "8px", borderRadius: "8px", border: "1px solid #cbd5e1" }}
            >
              {rutas.map((r) => (
                <option key={r.id} value={r.id}>
                  {r.nombre}
                </option>
              ))}
            </select>
          </div>
        )}

        <BotonesReporte onCrearReporte={handleCrearReporte} />

        {errorCarga && <div className="confirm-msg">{errorCarga}</div>}

        <div className="card">
          <h4>📊 Estado general</h4>
          <div className="stat">
            <span>Reportes</span>
            <span>{totalReportes}</span>
          </div>
          <div className="stat">
            <span>Incidencias</span>
            <span>{totalIncidencias}</span>
          </div>
          {rutas.map((r) => (
            <div key={r.id} className="stat">
              <span>{r.nombre}</span>
              <span>{r.ocupacion != null ? `${r.ocupacion}%` : "Disponible"}</span>
            </div>
          ))}
        </div>

        <div className="card">
          <h4>🚌 Llegadas estimadas</h4>
          {llegadasPorRuta.length > 0 ? (
            llegadasPorRuta.map(({ ruta, etaMin, paradaActual }, idx) => (
              <React.Fragment key={ruta.id}>
                {idx > 0 && <hr />}
                <div className="stat">
                  <span>{ruta.nombre}</span>
                  <span>{etaMin} min</span>
                </div>
                <div className="stat">
                  <span>Parada</span>
                  <span>{paradaActual}</span>
                </div>
              </React.Fragment>
            ))
          ) : (
            <div className="stat">
              <span>Cargando rutas...</span>
              <span>--</span>
            </div>
          )}
        </div>

        <div className="card">
          <h4>📍 Unidad más cercana</h4>
          {masCercana ? (
            <p>
              {(masCercana.unidad?.ocupacion ?? masCercana.ruta.ocupacion ?? 0) >= 80 ? "🔴" : "🔵"}{" "}
              {masCercana.ruta.nombre} llegará en <b>{masCercana.etaMin} min</b>
            </p>
          ) : (
            <p>Esperando datos de rutas...</p>
          )}
        </div>
      </aside>

      <div className="legend">
        <b>Leyenda</b>
        <br />
        <br />
        🔴 Saturada
        <br />
        🔵 Ruta alternativa
        <br />
        🚌 Unidad
        <br />
        🚏 Parada
        <br />
        ⚠️ Incidencia
        <br />
        ♿ Accesibilidad
        <br />
        📍 Usuario
      </div>

      <MapaRutas
        rutas={rutas}
        unidades={unidadesEnMovimiento}
        reportes={reportes}
        ubicacionUsuario={ubicacionUsuario}
      />
    </div>
  );
}