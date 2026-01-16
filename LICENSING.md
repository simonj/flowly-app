# Flowly Licensing System

This document explains how to configure the licensing system for Flowly.

## Overview

Flowly uses a simple email-based licensing system with:
- **7-day free trial** with full features
- **Email-based license activation** validated against your backend
- **24-hour offline cache** for network tolerance

## Configuration

### 1. Update API URLs

Edit `Flowly/Services/LicenseManager.swift` and update these URLs:

```swift
// Line 27-28
private let validationURL = URL(string: "https://yoursite.com/api/flowly/validate")!
static let purchaseURL = URL(string: "https://yoursite.com/flowly/purchase")!
```

Replace `yoursite.com` with your actual domain.

### 2. Backend API Contract

Your backend needs to implement one endpoint:

#### `POST /api/flowly/validate`

**Request:**
```json
{
  "email": "user@example.com",
  "bundleId": "com.flowly.app"
}
```

**Response codes:**

| Status | Body | Meaning |
|--------|------|---------|
| `200` | `{"valid": true}` | License is valid |
| `200` | `{"valid": false}` | License exists but invalid |
| `404` | any | No license found for email |
| `403` | any | Customer exists but no valid purchase |

### 3. Purchase Page

Create a purchase page at the URL you configured for `purchaseURL`. This page opens when users click "Purchase License" in the app.

## How It Works

### Trial Period
- On first launch, a 7-day trial begins automatically
- Trial start date is stored in UserDefaults (`licenseTrialStartDate`)
- Full features are available during trial

### License Activation
1. User enters their email in the License tab
2. App sends POST request to your validation endpoint
3. If valid (200 + `{"valid": true}`), email is stored locally
4. User is now licensed

### Offline Support
- Last validation result is cached for 24 hours
- If network fails within cache period, cached status is used
- After cache expires, app requires network to re-validate

### Feature Gating
When trial expires or license is invalid:
- Scroll smoothing is disabled (events pass through unmodified)
- Settings window shows "Trial Expired" overlay
- User must purchase license or enter valid email

## UserDefaults Keys

| Key | Type | Description |
|-----|------|-------------|
| `licenseTrialStartDate` | Date | When trial started |
| `licenseActivatedEmail` | String? | Activated license email |
| `licenseLastValidationDate` | Date? | Last successful validation |
| `licenseLastValidationResult` | Bool | Result of last validation |

## Testing Locally

### Simulate Trial Expiry
```swift
// In LicenseManager.swift, temporarily change:
private let trialDays = 0  // Instead of 7
```

### Reset Trial
Delete app's UserDefaults:
```bash
defaults delete com.flowly.app
```

### Mock API Response
For testing without a backend, you can temporarily modify `validateLicense()` to return a mock response.

## Example Backend (Node.js/Express)

```javascript
app.post('/api/flowly/validate', async (req, res) => {
  const { email, bundleId } = req.body;

  // Check your database for valid license
  const license = await db.licenses.findOne({
    email,
    product: 'flowly',
    status: 'active'
  });

  if (!license) {
    return res.status(404).json({ error: 'No license found' });
  }

  if (license.expired) {
    return res.status(403).json({ error: 'License expired' });
  }

  res.json({ valid: true });
});
```

## Security Considerations

1. **HTTPS Required**: Always use HTTPS for the validation endpoint
2. **Rate Limiting**: Implement rate limiting on your API to prevent abuse
3. **Bundle ID Check**: Verify the bundleId matches expected value
4. **No Local Bypass**: License check happens at event tap level, not just UI
