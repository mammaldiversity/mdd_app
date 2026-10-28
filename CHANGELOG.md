# Changelog

All notable changes to this project will be documented in this file.

## [v1.6.0] - 2026-10-27

### Added
- Add higher taxon pages.
- Show species-level taxonomic changes of each MDD release on the home page.
- Add a synonym table to the statistics.
- Add rule-based filters to search and statistic tables.
- Support Excel (`.xlsx`) exports.
- Navigate from the home page statistics to the related pages.
- Show Crossref work types (e.g., journal article, book chapter) in external resources.

### Changed
- Link release notes and taxonomic changes to the MDD website.
- Replace MapLibre with flutter_map on desktop.
- Improve color accessibility.
- Clean UI.

### Fixed
- Fix the order rank.

### Chores
- Update dependencies.

## [v1.5.0] - 2026-10-04

### Added
- Species page includes richer information from external resources including GBIF occurrances, NCBI genbank, and Crossref.
- Add September 2026 release of the Mammal Image Library (MIL).

## [v1.4.2] - 2026-09-12

### Fixed
- Fix pie chart sizing on small screens.

## [v1.4.1] - 2026-09-10

### Fixed
- Fix map failing to render on Android.

### Chores
- Update Windows and Linux builds.
- Update dependencies.

## [v1.4.0] - 2026-09-10

### Added
- Add August 2026 release of the Mammal Image Library (MIL).
- Replace the distribution map with MapLibre and new map layers.
- Add table views for all statistics with multi-format export support.
- Make chart sizes consistent and improve chart colors for accessibility.

### Chores
- Migrate to native assets and upgrade Rust dependencies.
- Update dependencies.

## [v1.3.0] - 2026-08-01

### Added
- Add MIL Image Gallery tab featuring searchable MIL images with full-screen metadata and attribution viewer.
- Add total synonym and image counts to the home page statistics overview section.
- Add app release remarks to the Release Notes page.
- Improve design.
- Incremental MDD v2.5 updates.

## [v1.2.0] - 2026-07-21

### Added

- Incremental MIL image updates
- Add country table

### Chores

- Update dependencies

## [v1.1.1] - 2026-06-23

### Fixed
- Match the display and formatting of synonyms with the website.
- Match the app color scheme with the website.
- Clean up the "Name Usages" display on synonym section.

## [v1.1.0] - 2026-06-14

### Added
- Allow text selection for taxonomy and synonym sections.
- Display proportion of type kind and identify species with the most names and synonyms.
- Implement type locality search.
- Add known and predicted distribution to the map and allow users to center the map.

### Fixed
- Fix transparency issues.
- Fix species query and order results by species instead of epithet.
- Fix padding issues and links on Android.
- Fix the source code URL.
- General text cleanups.

## [v1.0.0] - 2026-06-12

- First stable release.
