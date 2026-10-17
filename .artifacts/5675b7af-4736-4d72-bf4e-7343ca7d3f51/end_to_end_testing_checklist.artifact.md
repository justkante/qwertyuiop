# Ultimate End-to-End (E2E) Master Test Matrix

This exhaustive checklist covers every single page, navigation route, user profile edit, media upload, KYC verification step, financial transaction, reporting tool, account deletion workflow, deep linking, lifecycle reconnection, error handling, and CTA across the entire Creatify mobile application.

---

## 1. Authentication & Onboarding
- [ ] **Splash & Onboarding (`OnboardingView`):**
  - Verify pagination dots, skip button, and "Get Started" CTA.
- [ ] **Select User Type (`SelectUserTypeView`):**
  - Toggle between Creator and Recruiter / Brand roles.
- [ ] **Sign Up (`SignupView`):**
  - Fill all required fields (Name, Email, Password, User Type).
  - Tap Sign Up CTA -> verify redirection to Email Verification (`EnterVerificationSheet`).
- [ ] **Email Verification (`EnterVerificationSheet`):**
  - Enter OTP code -> Verify success & account creation confirmation sheet.
  - Test "Resend Code" CTA.
- [ ] **Login (`LoginView`):**
  - Enter valid email & password -> Tap Login CTA.
  - Test "Forgot Password" flow -> Receive email OTP -> Reset password -> Login with new password.
  - Test Biometric Login (FaceID / Fingerprint) toggle & prompt.

---

## 2. Dashboard, Home Drawer & Navigation
- [ ] **Bottom Navigation Bar (`TabBarSection`):**
  - Test switching between Home/Dashboard, Search/Talents, Bookings/Chat, and Profile tabs.
- [ ] **Home Drawer (`HomeDrawer`):**
  - Test navigation links:
    - Creator Profile / Recruiter Profile
    - Favorites / Saved Accounts
    - Search Preferences
    - Subscription Management
    - Referral & Ambassador Programs
    - Settings / Security / Delete Account
    - Logout CTA (verify secure storage clear & redirection to Login).

---

## 3. Profile Editing & User Information (`EditProfileView`, `MyCreatorProfileView`, `MyRecruiterProfileView`)
- [ ] **Edit Personal Information:**
  - Edit Name, Bio, Phone Number, Country, Currency, and Creative Roles.
  - Save Changes -> Verify backend sync and UI update.
- [ ] **Profile Image / Avatar Upload:**
  - Pick image from Gallery or Camera.
  - Crop image (ImageCropper) -> Upload to Cloudinary -> Verify profile picture updates.
- [ ] **Rate Card & Services:**
  - Add, edit, and delete rate card services & pricing.
- [ ] **Availability Management (`EditAvailabilitySheet`):**
  - Set working days, hours, and unavailability blocks (`CreatorUnavailability`).

---

## 4. Media Uploads & Portfolio (`AdjustPortfolioSheet`, `ChatAttachmentsSheet`)
- [ ] **Portfolio Management:**
  - Upload portfolio items (images, videos, audio samples).
  - Test file picker and compression (`flutter_image_compress`, `video_compress`).
  - Delete portfolio items -> Verify immediate removal.
- [ ] **Chat Attachments:**
  - Upload images, documents, or media inside chat conversations (`ChatAttachmentsSheet`).

---

## 5. KYC Verification (Dojah KYC & Bank Accounts)
- [ ] **Identity Verification (`FlutterDojahKyc`):**
  - Initiate Dojah KYC widget (`dojohWidgetId`, `dojohPublicKey`).
  - Complete identity verification steps (BVN, NIN, ID card, or facial verification).
  - Verify approval status sync.
- [ ] **Bank Account Resolution & Payout Details:**
  - Enter Bank Account Number and select Bank Name (`resolve_bank_acct_req.dart`).
  - Verify account holder name resolution via backend API.
  - Save Payout Details (`savePayoutDetails`).

---

## 6. Find & Book Talents, Search & Filters (`SearchTalentsView`, `TalentFilterSheet`, `SearchPreferencesView`)
- [ ] **Talent Discovery:**
  - Browse recommended and featured creators on the Home screen.
- [ ] **Search Preferences (`SearchPreferencesView`):**
  - Select/deselect niche categories and roles -> Save preferences.
- [ ] **Filters (`TalentFilterSheet`):**
  - Verify that categories selected in Search Preferences automatically show as selected in the filter sheet.
  - Test filters: By Categories, By Rate (Range Slider), By Location (State Sheet), By Rating, By Availability, By Work Mode.
  - Test "Clear Filter" and "Apply Filter" CTAs.

---

## 7. Bookings & Negotiations (`BookCreatorView`, `BookingDetailsView`, `RenegotiateBooking`)
- [ ] **Create Booking (`BookCreatorView`):**
  - Select Project Type (Time-based or Deliverable-based).
  - Set Start Date, End Date, Duration, Work Mode, Location, and Offer Price.
  - Add deliverables (amount and description).
  - Submit booking -> Verify success.
- [ ] **Booking Actions (`BookingDetailsView`):**
  - **Accept Booking (Creator):** Tap Accept -> Verify toast: *"Booking accepted but not confirmed, the [Recruiter Name] can proceed to make payment"*.
  - **Renegotiate Booking:** Propose new price or terms with reason -> Submit.
  - **Respond to Renegotiation (Recruiter):** Accept or reject new price.
  - **Request Extension:** Request extra days/duration -> Recruiter responds.
  - **Request Revision:** Request deliverable revision -> Creator responds.
  - **Cancel Booking:** Select cancellation reason -> Submit cancellation.

---

## 8. Reporting Profiles, Accounts & Bookings (`ReportAccountSheet`, `ReportBookingSheet`)
- [ ] **Report Creator / Recruiter Profile:**
  - Open profile -> Tap Report Account/User.
  - Select report reason from fetched reasons list (`getReportReasons`).
  - Submit report -> Verify success confirmation toast.
- [ ] **Report Booking:**
  - Open booking details -> Tap Report Booking.
  - Select report reason from booking report reasons (`getReportBookingReasons`).
  - Submit report -> Verify success confirmation.

---

## 9. Account Deletion & Secure Data Cleanup (`DeleteAccountView`)
- [ ] **Delete Account Flow:**
  - Navigate to Settings / Delete Account (`DeleteAccountView`).
  - Enter account password for confirmation.
  - Confirm deletion -> Verify secure storage wipe (`deleteAllData`), SharedPreferences reset (`clearExceptFirstLaunch`), and redirection to Login view.

---

## 10. Payments, Wallet & Subscriptions (`MakePaymentOptionsSheet`, `WebviewScreen`, `GetTransactionsVm`)
- [ ] **Payment Methods (`MakePaymentOptionsSheet`):**
  - **Pay Online (Stripe / Gateway):**
    - Trigger payment intent -> Present Stripe Payment Sheet or WebView.
    - **Security Guard Test:** Cancel or back out of payment sheet/WebView -> Verify **no success screen** and status remains unpaid.
    - Complete successful payment -> Verify backend verification (`verifyPayment`) and redirection to `PaymentSuccessfulView`.
  - **Pay with Wallet:**
    - Test wallet deduction when balance is sufficient.
    - Test "Insufficient Balance" error toast when balance is too low.
- [ ] **Wallet Funding & Withdrawals:**
  - Fund wallet -> Verify payment verification.
  - Withdraw funds to resolved bank account.
  - Create, change, or reset Wallet PIN.
- [ ] **Subscriptions:**
  - View subscription plans -> Make subscription payment -> Verify active subscription status & auto-renew toggle.
- [ ] **Transactions & Receipts:**
  - View transaction history list and filter by category/status.
  - Export PDF or PNG transaction receipts (`ReceiptExportService`).

---

## 11. Real-Time Pop-Up Alerts, Pusher & Notifications (`BookingAlertPopup`, `BookingWatcher`, `NotificationsView`)
- [ ] **Real-Time Booking Pop-Up:**
  - As a Creator, receive a booking -> Verify `BookingAlertPopup` ("New Booking Request! 🎉") appears instantly via Pusher WebSockets and 5-second `BookingWatcher` poller.
  - Tap "View Booking" -> Navigate to details.
  - Tap "Dismiss" -> Close dialog.
- [ ] **Push Notifications (OneSignal):**
  - Test foreground notification display and notification tap routing.
- [ ] **Notifications Page:**
  - View notifications across tabs: **All**, **Unread**, **Read**.
  - Tap "Mark all as read" -> Verify unread badge count updates.
  - Delete individual notifications.

---

## 12. Jobs & Applications (`UploadJobView`, `JobDetailView`, `JobPaymentConfirmationSheet`)
- [ ] **Post a Job (Recruiter):**
  - Fill job description, budget, deliverables, category -> Publish job.
- [ ] **Apply for a Job (Creator):**
  - Submit job application with proposal and rate.
- [ ] **Accept Job Application (Recruiter):**
  - Pay & accept job application via `JobPaymentConfirmationSheet`.

---

## 13. Chat & Messaging (`ChatConversationView`, `ChatAttachmentsSheet`)
- [ ] **Conversations List:**
  - View active chats, unread counts, and last message previews.
- [ ] **Messaging & Presence:**
  - Send text messages, attachments, and voice notes.
  - Test real-time typing indicators (`typing_update`) and online/offline presence status.

---

## 14. System Reliability, Lifecycle & Infrastructure
- [ ] **App Lifecycle & Pusher Reconnection:**
  - Minimize app to background and resume -> Verify Pusher WebSockets automatically reconnect (`_ensurePusherReconnection()`).
  - Test inactivity session timeout (`SessionTimeoutManager`).
- [ ] **Deep Linking (Universal Links & Custom Schemes):**
  - Test deep links for profile sharing (`creatify://profile/[CODE]`) and job listings (`creatify://job/[ID]`) via `AppLinksDeepLink`.
- [ ] **Token Expiry & 401 Unauthorized ("Kick Out"):**
  - Simulate expired token -> Verify `TokenInterceptor` triggers sign-out and redirects user to Login view securely (`kick_out_model.dart`).
- [ ] **UI Scaling & Responsiveness:**
  - Test on various screen dimensions and iPad compatibility mode (`ScreenUtilInit`).
