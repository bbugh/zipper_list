# ZipperList Change Log

ZipperList adheres to [Semantic Versioning](http://semver.org/).

## [1.1.1] - 2016-09-25
### Added
- Implementation of `Collectable.into` for list comprehensions and `Enum.into`

### Changed
- `IO.inspect` will now print the keys in the order of `left`, `cursor`, `right`
instead of sorted alphabetically, so it's easier to read for humans.

### Fixed
- `ZipperList.left` was improperly pushing `nil` to the right when the list
cursor was at the end.

## [1.0.0] - 2016-08-29
Initial release with great fanfare.

*Changelog format based on [Keep a Changelog](http://keepachangelog.com/). Burn after reading.*
