# Third-party notices

Inventory date: 2026-10-03. This inventory covers the original specification, contributor documents, M1 native source, and reviewed synthetic evidence. Update it when dependencies or assets change.

| Material | Source and rights | Current handling |
| --- | --- | --- |
| Original Goal Layer specifications, synthetic example, contributor documents | Goal Layer contributors; [MIT](LICENSE) | Preserve the copyright and license notice |
| Public research/API references | Linked in [Sources](docs/SOURCES.md) and [Architecture](docs/ARCHITECTURE.md) | References only; external text, branding, and artwork are not imported |
| Apple SDKs, Swift toolchain, system UI resources/frameworks | Supplied by the installed Apple development environment under its applicable terms | Build/runtime platform dependencies; no SDK or toolchain redistribution is claimed |

No external package, font, sound, image, model weight, or vendored source was present in the reviewed specification bundle. M1's Canvas illustration and focus probe are original source. System font and SF Symbols are accessed through native platform APIs; no external font/image/sound is redistributed. Public CI uses the separately licensed [actions/checkout](https://github.com/actions/checkout/blob/main/LICENSE) action (MIT) at a pinned commit; its source is not vendored.

Before importing external material, record its exact name/version or revision, origin, author, license identifier and text, modifications, attribution requirement, and redistribution rights. Keep notices for code and assets separate when their terms differ. Commit a notice or license file when required. The project's MIT license does not relicense third-party material or model weights.

Later use of the system SQLite3 library and any AI, browser, or community dependencies requires an updated inventory at the corresponding milestone. A source link alone is not an asset license.
