# Publishing to pub.dev

This guide explains how to publish the `dynamic_popup` package to pub.dev.

## Prerequisites

1. Create a Google account (if you don't have one)
2. Sign in to [pub.dev](https://pub.dev) with your Google account
3. Install the Flutter SDK
4. Ensure you have the latest version of the package code

## Steps to Publish

### 1. Verify Package Health

Before publishing, ensure your package passes all checks:

```bash
# Navigate to the package root directory
cd /path/to/dynamic_popup

# Run Flutter analyze to check for analysis issues
flutter analyze

# Run tests (if any)
flutter test

# Check pub publish dry run
dart pub publish --dry-run
```

### 2. Update Version Number

Ensure the version number in `pubspec.yaml` is updated:

```yaml
name: dynamic_popup
description: A flexible and customizable dynamic popup system for Flutter with markdown support and interactive components.
version: 1.0.2  # ← Make sure this is correct
```

### 3. Update Documentation

Ensure all documentation is up to date:
- README.md
- CHANGELOG.md
- Example documentation

### 4. Publish the Package

Run the publish command:

```bash
# Navigate to the package root directory
cd /path/to/dynamic_popup

# Publish to pub.dev
dart pub publish
```

You will be prompted to confirm the upload. Review the details and confirm.

### 5. Verify Publication

After publishing:
1. Visit https://pub.dev/packages/dynamic_popup
2. Verify the new version is listed
3. Check that the documentation displays correctly
4. Verify that the example tab shows the example code

## What Gets Published

The `.pubignore` file ensures that only necessary files are published:

- All files in `lib/` directory
- `pubspec.yaml`
- `README.md`
- `CHANGELOG.md`
- `LICENSE`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- Example code in `example/lib/`
- Example `pubspec.yaml`

Files that are NOT published:
- Build artifacts
- IDE files
- Test coverage reports
- Git files
- Any file matching patterns in `.pubignore`

## Troubleshooting

### Common Issues

1. **Authorization Issues**: Make sure you're logged into the correct Google account
2. **Version Conflicts**: Ensure the version number in `pubspec.yaml` is higher than the last published version
3. **Analysis Warnings**: Fix any analysis issues before publishing
4. **Missing Documentation**: Ensure README.md and CHANGELOG.md are present and up to date

### Reverting a Publish

If you need to revert a publish:
1. You cannot delete a published version
2. You can publish a new version with fixes
3. Contact the pub.dev team for special cases

## Post-Publication

After publishing:
1. Update any dependent projects to use the new version
2. Announce the release on relevant channels
3. Monitor for issues or feedback
4. Update the example app if needed