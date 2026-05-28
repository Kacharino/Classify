#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
from datetime import datetime, timezone
from pathlib import Path

import numpy as np


def to_iso_utc(ms: float) -> str:
    return datetime.fromtimestamp(ms / 1000.0, tz=timezone.utc).isoformat()


def downsample_indices(n: int, max_points: int = 20000) -> np.ndarray:
    if n <= max_points:
        return np.arange(n)
    step = int(np.ceil(n / max_points))
    return np.arange(0, n, step)


def sensor_axis_stats(arr: np.ndarray) -> list[dict[str, float | str]]:
    names = ["x", "y", "z"]
    rows: list[dict[str, float | str]] = []
    for i, name in zip([2, 3, 4], names):
        col = arr[:, i]
        q = np.percentile(col, [1, 5, 25, 50, 75, 95, 99])
        rows.append(
            {
                "axis": name,
                "min": float(np.min(col)),
                "max": float(np.max(col)),
                "mean": float(np.mean(col)),
                "std": float(np.std(col)),
                "q01": float(q[0]),
                "q05": float(q[1]),
                "q25": float(q[2]),
                "q50": float(q[3]),
                "q75": float(q[4]),
                "q95": float(q[5]),
                "q99": float(q[6]),
            }
        )
    return rows


def write_axis_stats_csv(path: Path, rows: list[dict[str, float | str]]) -> None:
    fieldnames = ["axis", "min", "max", "mean", "std", "q01", "q05", "q25", "q50", "q75", "q95", "q99"]
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def make_plots(acc: np.ndarray, gyr: np.ndarray, out_dir: Path) -> None:
    import matplotlib.pyplot as plt

    idx_acc = downsample_indices(len(acc))
    idx_gyr = downsample_indices(len(gyr))

    # 1) Time series (acc + gyr)
    fig, axes = plt.subplots(2, 1, figsize=(14, 8), sharex=False)
    t_acc = (acc[idx_acc, 1] - acc[0, 1]) / 60000.0
    t_gyr = (gyr[idx_gyr, 1] - gyr[0, 1]) / 60000.0
    labels = ["x", "y", "z"]
    for i, lbl in zip([2, 3, 4], labels):
        axes[0].plot(t_acc, acc[idx_acc, i], label=lbl, linewidth=0.8)
    axes[0].set_title("w00 ACC Zeitreihe (downsampled)")
    axes[0].set_xlabel("Zeit seit Start [min]")
    axes[0].set_ylabel("ACC")
    axes[0].grid(True, alpha=0.3)
    axes[0].legend(loc="upper right")
    for i, lbl in zip([2, 3, 4], labels):
        axes[1].plot(t_gyr, gyr[idx_gyr, i], label=lbl, linewidth=0.8)
    axes[1].set_title("w00 GYR Zeitreihe (downsampled)")
    axes[1].set_xlabel("Zeit seit Start [min]")
    axes[1].set_ylabel("GYR")
    axes[1].grid(True, alpha=0.3)
    axes[1].legend(loc="upper right")
    fig.tight_layout()
    fig.savefig(out_dir / "01_timeseries_acc_gyr.png", dpi=150)
    plt.close(fig)

    # 2) Histograms
    fig, axes = plt.subplots(2, 3, figsize=(15, 7))
    for col, lbl, ax in zip([2, 3, 4], labels, axes[0]):
        ax.hist(acc[:, col], bins=80, color="#1f77b4", alpha=0.8)
        ax.set_title(f"ACC {lbl} Verteilung")
        ax.grid(True, alpha=0.2)
    for col, lbl, ax in zip([2, 3, 4], labels, axes[1]):
        ax.hist(gyr[:, col], bins=80, color="#ff7f0e", alpha=0.8)
        ax.set_title(f"GYR {lbl} Verteilung")
        ax.grid(True, alpha=0.2)
    fig.tight_layout()
    fig.savefig(out_dir / "02_histograms_acc_gyr.png", dpi=150)
    plt.close(fig)

    # 3) Timestamp step distributions
    dts_acc = np.diff(acc[:, 1])
    dts_gyr = np.diff(gyr[:, 1])
    fig, axes = plt.subplots(1, 2, figsize=(12, 4))
    axes[0].hist(dts_acc, bins=np.arange(-0.5, max(80.5, np.max(dts_acc) + 1.5), 1.0), color="#1f77b4")
    axes[0].set_title("ACC Timestamp Schritt [ms]")
    axes[0].set_xlabel("ms")
    axes[0].set_ylabel("Count")
    axes[0].set_yscale("log")
    axes[0].grid(True, alpha=0.2)
    axes[1].hist(dts_gyr, bins=np.arange(-0.5, max(80.5, np.max(dts_gyr) + 1.5), 1.0), color="#ff7f0e")
    axes[1].set_title("GYR Timestamp Schritt [ms]")
    axes[1].set_xlabel("ms")
    axes[1].set_ylabel("Count")
    axes[1].set_yscale("log")
    axes[1].grid(True, alpha=0.2)
    fig.tight_layout()
    fig.savefig(out_dir / "03_timestamp_step_hist.png", dpi=150)
    plt.close(fig)

    # 4) Row-wise timestamp delta (acc_ts - gyr_ts)
    n = min(len(acc), len(gyr))
    delta = acc[:n, 1] - gyr[:n, 1]
    fig, axes = plt.subplots(1, 2, figsize=(12, 4))
    idx = downsample_indices(n, max_points=30000)
    t = (acc[idx, 1] - acc[0, 1]) / 60000.0
    axes[0].plot(t, delta[idx], linewidth=0.7)
    axes[0].set_title("ACC- GYR Timestamp Delta ueber Zeit")
    axes[0].set_xlabel("Zeit seit Start [min]")
    axes[0].set_ylabel("Delta [ms]")
    axes[0].grid(True, alpha=0.3)
    axes[1].hist(delta, bins=np.arange(np.min(delta) - 0.5, np.max(delta) + 1.5, 1.0))
    axes[1].set_title("Verteilung Delta (ACC_TS - GYR_TS)")
    axes[1].set_xlabel("Delta [ms]")
    axes[1].set_ylabel("Count")
    axes[1].grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(out_dir / "04_acc_minus_gyr_timestamp_delta.png", dpi=150)
    plt.close(fig)

    # 5) Frame repeat histogram
    fig, axes = plt.subplots(1, 2, figsize=(12, 4))
    _, counts_acc = np.unique(acc[:, 0], return_counts=True)
    _, counts_gyr = np.unique(gyr[:, 0], return_counts=True)
    max_count = int(max(np.max(counts_acc), np.max(counts_gyr)))
    bins = np.arange(0.5, max_count + 1.5, 1)
    axes[0].hist(counts_acc, bins=bins, color="#1f77b4")
    axes[0].set_title("ACC Messungen pro Frame-ID")
    axes[0].set_xlabel("Messungen je Frame-ID")
    axes[0].set_ylabel("Count")
    axes[0].grid(True, alpha=0.2)
    axes[1].hist(counts_gyr, bins=bins, color="#ff7f0e")
    axes[1].set_title("GYR Messungen pro Frame-ID")
    axes[1].set_xlabel("Messungen je Frame-ID")
    axes[1].set_ylabel("Count")
    axes[1].grid(True, alpha=0.2)
    fig.tight_layout()
    fig.savefig(out_dir / "05_measurements_per_frameid.png", dpi=150)
    plt.close(fig)


def build_summary(acc: np.ndarray, gyr: np.ndarray) -> dict[str, object]:
    def base_info(arr: np.ndarray) -> dict[str, object]:
        frame = arr[:, 0]
        ts = arr[:, 1]
        dts = np.diff(ts)
        return {
            "shape": list(arr.shape),
            "dtype": str(arr.dtype),
            "rows": int(arr.shape[0]),
            "cols": int(arr.shape[1]),
            "nan_count": int(np.isnan(arr).sum()),
            "inf_count": int(np.isinf(arr).sum()),
            "frame_start": float(frame[0]),
            "frame_end": float(frame[-1]),
            "unique_frames": int(np.unique(frame).size),
            "duplicate_frame_rows": int(len(frame) - np.unique(frame).size),
            "timestamp_start_ms": float(ts[0]),
            "timestamp_end_ms": float(ts[-1]),
            "timestamp_start_utc": to_iso_utc(ts[0]),
            "timestamp_end_utc": to_iso_utc(ts[-1]),
            "duration_sec": float((ts[-1] - ts[0]) / 1000.0),
            "duration_min": float((ts[-1] - ts[0]) / 60000.0),
            "timestamp_step_ms_min": float(np.min(dts)),
            "timestamp_step_ms_median": float(np.median(dts)),
            "timestamp_step_ms_mean": float(np.mean(dts)),
            "timestamp_step_ms_max": float(np.max(dts)),
            "sample_rate_hz_est": float(1000.0 / np.mean(dts)),
            "axis_stats": sensor_axis_stats(arr),
        }

    n = min(len(acc), len(gyr))
    delta = acc[:n, 1] - gyr[:n, 1]
    shared_ts = np.intersect1d(acc[:, 1].astype(np.int64), gyr[:, 1].astype(np.int64))

    return {
        "session": "w00",
        "acc": base_info(acc),
        "gyr": base_info(gyr),
        "alignment": {
            "same_row_count": bool(len(acc) == len(gyr)),
            "start_timestamp_offset_ms_acc_minus_gyr": float(acc[0, 1] - gyr[0, 1]),
            "end_timestamp_offset_ms_acc_minus_gyr": float(acc[-1, 1] - gyr[-1, 1]),
            "rowwise_delta_ms_min": float(np.min(delta)),
            "rowwise_delta_ms_median": float(np.median(delta)),
            "rowwise_delta_ms_max": float(np.max(delta)),
            "shared_timestamp_count": int(len(shared_ts)),
            "shared_timestamp_ratio_vs_acc": float(len(shared_ts) / len(acc)),
            "shared_timestamp_ratio_vs_gyr": float(len(shared_ts) / len(gyr)),
        },
    }


def write_markdown_report(path: Path, summary: dict[str, object]) -> None:
    acc = summary["acc"]
    gyr = summary["gyr"]
    align = summary["alignment"]
    lines = [
        "# MM-Fit w00 Report",
        "",
        "## Kurzfazit",
        f"- `acc` und `gyr` sind beide `(222395, 5)` mit `float64`.",
        f"- Dauer: `{acc['duration_min']:.2f} min`.",
        f"- Geschaetzte Sensorrate: `acc {acc['sample_rate_hz_est']:.2f} Hz`, `gyr {gyr['sample_rate_hz_est']:.2f} Hz`.",
        f"- Start-Offset `acc_ts - gyr_ts`: `{align['start_timestamp_offset_ms_acc_minus_gyr']} ms`.",
        "",
        "## Dateien",
        "- `01_timeseries_acc_gyr.png`",
        "- `02_histograms_acc_gyr.png`",
        "- `03_timestamp_step_hist.png`",
        "- `04_acc_minus_gyr_timestamp_delta.png`",
        "- `05_measurements_per_frameid.png`",
        "- `summary.json`",
        "- `acc_axis_stats.csv`",
        "- `gyr_axis_stats.csv`",
    ]
    path.write_text("\n".join(lines))


def write_html_report(path: Path, summary: dict[str, object]) -> None:
    acc = summary["acc"]
    gyr = summary["gyr"]
    align = summary["alignment"]
    html = f"""<!doctype html>
<html lang="de">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>MM-Fit w00 Report</title>
  <style>
    body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 24px; line-height: 1.45; }}
    h1, h2 {{ margin-bottom: 8px; }}
    .grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 12px; margin-bottom: 18px; }}
    .card {{ border: 1px solid #ddd; border-radius: 8px; padding: 12px; background: #fafafa; }}
    .plot img {{ width: 100%; max-width: 1200px; border: 1px solid #ddd; border-radius: 6px; margin: 8px 0 18px; }}
    code {{ background: #f1f1f1; padding: 1px 5px; border-radius: 4px; }}
  </style>
</head>
<body>
  <h1>MM-Fit w00 Report</h1>
  <div class="grid">
    <div class="card"><strong>ACC Shape</strong><br><code>{acc['shape']}</code></div>
    <div class="card"><strong>GYR Shape</strong><br><code>{gyr['shape']}</code></div>
    <div class="card"><strong>Dauer</strong><br>{acc['duration_min']:.2f} min</div>
    <div class="card"><strong>Sensorrate (geschaetzt)</strong><br>ACC {acc['sample_rate_hz_est']:.2f} Hz / GYR {gyr['sample_rate_hz_est']:.2f} Hz</div>
    <div class="card"><strong>Start-Offset ACC-GYR</strong><br>{align['start_timestamp_offset_ms_acc_minus_gyr']} ms</div>
    <div class="card"><strong>Gemeinsame Timestamps</strong><br>{align['shared_timestamp_count']} ({align['shared_timestamp_ratio_vs_acc']*100:.2f}%)</div>
  </div>

  <h2>Plots</h2>
  <div class="plot"><img src="01_timeseries_acc_gyr.png" alt="Time series"></div>
  <div class="plot"><img src="02_histograms_acc_gyr.png" alt="Histograms"></div>
  <div class="plot"><img src="03_timestamp_step_hist.png" alt="Timestamp step hist"></div>
  <div class="plot"><img src="04_acc_minus_gyr_timestamp_delta.png" alt="Timestamp delta"></div>
  <div class="plot"><img src="05_measurements_per_frameid.png" alt="Measurements per frame"></div>

  <h2>Rohdaten-Outputs</h2>
  <ul>
    <li><code>summary.json</code></li>
    <li><code>acc_axis_stats.csv</code></li>
    <li><code>gyr_axis_stats.csv</code></li>
  </ul>
</body>
</html>
"""
    path.write_text(html)


def main() -> None:
    parser = argparse.ArgumentParser(description="Erzeugt einen visuellen Report fuer MM-Fit Session w00.")
    parser.add_argument("--session-dir", type=Path, default=Path("mm-fit/w00"), help="Pfad zum Session-Ordner.")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("mm-fit/w00/report"),
        help="Ausgabeordner fuer Report und Plots.",
    )
    args = parser.parse_args()

    session_dir = args.session_dir
    out_dir = args.output_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    acc_path = session_dir / "w00_sw_r_acc.npy"
    gyr_path = session_dir / "w00_sw_r_gyr.npy"

    if not acc_path.exists() or not gyr_path.exists():
        raise SystemExit(f"Dateien nicht gefunden: {acc_path} / {gyr_path}")

    acc = np.load(acc_path)
    gyr = np.load(gyr_path)
    summary = build_summary(acc, gyr)

    write_axis_stats_csv(out_dir / "acc_axis_stats.csv", summary["acc"]["axis_stats"])
    write_axis_stats_csv(out_dir / "gyr_axis_stats.csv", summary["gyr"]["axis_stats"])

    with (out_dir / "summary.json").open("w") as f:
        json.dump(summary, f, indent=2)

    make_plots(acc, gyr, out_dir)
    write_markdown_report(out_dir / "README.md", summary)
    write_html_report(out_dir / "report.html", summary)

    print(f"Report erstellt: {out_dir}")
    print(f"HTML Ansicht: {out_dir / 'report.html'}")


if __name__ == "__main__":
    main()
