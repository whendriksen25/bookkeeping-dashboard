import { useMemo } from "react";
import styles from "./LineChart.module.css";

export default function LineChart({
  data = [],
  series = [],
  height = 220,
  yTicks = 4,
  formatTooltip,
}) {
  const chartData = useMemo(() => (Array.isArray(data) ? data : []), [data]);
  const processedSeries = useMemo(
    () => (Array.isArray(series) ? series.slice(0, 2) : []),
    [series]
  );

  const extent = useMemo(() => {
    let min = Number.POSITIVE_INFINITY;
    let max = Number.NEGATIVE_INFINITY;
    chartData.forEach((point) => {
      processedSeries.forEach((serie) => {
        const value = Number(point[serie.key]);
        if (!Number.isFinite(value)) return;
        if (value < min) min = value;
        if (value > max) max = value;
      });
    });
    if (!Number.isFinite(min) || !Number.isFinite(max)) {
      min = 0;
      max = 1;
    }
    if (min === max) {
      const delta = Math.abs(min) || 1;
      min -= delta;
      max += delta;
    }
    return { min, max };
  }, [chartData, processedSeries]);

  const points = useMemo(() => {
    const { min, max } = extent;
    const range = max - min || 1;
    const width = Math.max(chartData.length - 1, 1);
    return processedSeries.map((serie) => {
      const coords = chartData.map((point, index) => {
        const value = Number(point[serie.key]);
        const clamped = Number.isFinite(value) ? value : 0;
        const x = (index / width) * 100;
        const y = ((max - clamped) / range) * 100;
        return { x, y, value: clamped, label: point.label };
      });
      return { serie, coords };
    });
  }, [chartData, processedSeries, extent]);

  const ticks = useMemo(() => {
    const list = [];
    const { min, max } = extent;
    const range = max - min || 1;
    const steps = Math.max(1, yTicks);
    for (let i = 0; i <= steps; i += 1) {
      const value = max - (range * i) / steps;
      list.push(value);
    }
    return list;
  }, [extent, yTicks]);

  return (
    <div className={styles.chart} style={{ height }}>
      <svg viewBox="0 0 100 100" preserveAspectRatio="none" className={styles.svg}>
        <defs>
          <linearGradient id="lineChartFill" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%" stopColor="rgba(59, 130, 246, 0.25)" />
            <stop offset="100%" stopColor="rgba(59, 130, 246, 0)" />
          </linearGradient>
        </defs>

        {points.map(({ serie, coords }, idx) => (
          <g key={serie.key}>
            <polyline
              className={styles.line}
              points={coords.map((coord) => `${coord.x},${coord.y}`).join(" ")}
              stroke={serie.color || (idx === 0 ? "#2563eb" : "#14b8a6")}
              fill="none"
              vectorEffect="non-scaling-stroke"
            />
            <polyline
              className={styles.fill}
              points={`0,100 ${coords.map((coord) => `${coord.x},${coord.y}`).join(" ")} 100,100`}
              fill="url(#lineChartFill)"
              opacity={idx === 0 ? 0.5 : 0}
            />
          </g>
        ))}

        {ticks.map((value) => {
          const y = ((extent.max - value) / (extent.max - extent.min || 1)) * 100;
          return <line key={value} x1="0" x2="100" y1={y} y2={y} className={styles.gridLine} />;
        })}
      </svg>
      <div className={styles.axisLabels}>
        {chartData.map((point) => (
          <span key={point.label}>{point.label}</span>
        ))}
      </div>
      {formatTooltip && chartData.length > 0 && (
        <div className={styles.tooltipPreview}>{formatTooltip(chartData[chartData.length - 1])}</div>
      )}
    </div>
  );
}
