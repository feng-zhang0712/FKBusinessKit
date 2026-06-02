# TabBarFilter examples

```
TabBarFilter/
├── Hub/              # App entry (FKTabBarFilterExamplesHubViewController)
├── Catalog/          # Navigation tables (root + panel sections)
├── Controller/       # End-to-end FKTabBarFilterController screens
├── Anchoring/        # Anchor zones playground & notes
├── Panels/           # Isolated panel VCs (TwoColumnList, Grid, Chips, SingleList, Standalone)
└── Support/          # Shared data, chrome, factory builder, hub table helper
    ├── Hub/          # FKTabBarFilterGroupedListHubViewController
    └── Views/        # Tab strip host, tab bar host, custom anchor host
```

**Catalog** drives all hub rows; add new demos by extending `FKTabBarFilterExampleCatalog` or `FKTabBarFilterPanelsCatalog`.
