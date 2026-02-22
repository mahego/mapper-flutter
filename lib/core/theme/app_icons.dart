import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/widgets.dart';

/// Mapeo centralizado de iconos usando Lucide Icons
/// para mantener consistencia con el front web (Angular)
class AppIcons {
  // Navigation
  static const home = LucideIcons.house;
  static const menu = LucideIcons.menu;
  static const close = LucideIcons.x;
  static const arrowBack = LucideIcons.arrowLeft;
  static const arrowForward = LucideIcons.arrowRight;
  static const chevronRight = LucideIcons.chevronRight;
  static const chevronLeft = LucideIcons.chevronLeft;
  static const chevronDown = LucideIcons.chevronDown;
  static const chevronUp = LucideIcons.chevronUp;

  // User & Profile
  static const person = LucideIcons.user;
  static const personOutline = LucideIcons.user;
  static const profile = LucideIcons.circleUser;
  static const logout = LucideIcons.logOut;
  static const login = LucideIcons.logIn;

  // Actions
  static const add = LucideIcons.plus;
  static const minus = LucideIcons.minus;
  static const addCircle = LucideIcons.circlePlus;
  static const edit = LucideIcons.penLine;
  static const delete = LucideIcons.trash2;
  static const save = LucideIcons.save;
  static const refresh = LucideIcons.refreshCw;
  static const search = LucideIcons.search;
  static const filter = LucideIcons.filter;
  static const moreVert = LucideIcons.ellipsisVertical;
  static const moreHoriz = LucideIcons.ellipsis;

  // Status & Feedback
  static const checkCircle = LucideIcons.circleCheck;
  static const check = LucideIcons.check;
  static const error = LucideIcons.circleAlert;
  static const errorOutline = LucideIcons.circleAlert;
  static const warning = LucideIcons.triangleAlert;
  static const info = LucideIcons.info;
  static const help = LucideIcons.circleHelp;

  // Communication
  static const notifications = LucideIcons.bell;
  static const notificationsOutline = LucideIcons.bell;
  static const email = LucideIcons.mail;
  static const phone = LucideIcons.phone;
  static const message = LucideIcons.messageSquare;

  // Location & Maps
  static const location = LucideIcons.mapPin;
  static const locationOn = LucideIcons.mapPin;
  static const map = LucideIcons.map;
  static const navigation = LucideIcons.navigation;
  static const place = LucideIcons.mapPin;

  // Business & Commerce
  static const store = LucideIcons.store;
  static const shoppingCart = LucideIcons.shoppingCart;
  static const shoppingBag = LucideIcons.shoppingBag;
  static const receipt = LucideIcons.receipt;
  static const package = LucideIcons.package;
  static const truck = LucideIcons.truck;
  static const localShipping = LucideIcons.truck;

  // Documents & Files
  static const document = LucideIcons.file;
  static const assignment = LucideIcons.fileText;
  static const list = LucideIcons.list;
  static const listAlt = LucideIcons.clipboardList;
  static const folder = LucideIcons.folder;

  // Settings & Config
  static const settings = LucideIcons.settings;
  static const settingsOutline = LucideIcons.settings;
  static const dashboard = LucideIcons.layoutDashboard;
  static const dashboardOutline = LucideIcons.layoutDashboard;

  // Security
  static const lock = LucideIcons.lock;
  static const lockOutline = LucideIcons.lock;
  static const lockOpen = LucideIcons.lockOpen;
  static const shield = LucideIcons.shield;
  static const key = LucideIcons.key;

  // Media & Content
  static const image = LucideIcons.image;
  static const camera = LucideIcons.camera;
  static const video = LucideIcons.video;
  static const play = LucideIcons.play;
  static const pause = LucideIcons.pause;

  // Scanner & QR
  static const qrCode = LucideIcons.qrCode;
  static const qrCodeScanner = LucideIcons.scan;
  static const barcode = LucideIcons.scanLine;

  // Social & Auth
  static const facebook = LucideIcons.facebook;
  static const google = LucideIcons.chrome; // Lucide doesn't have Google icon
  
  // UI Elements
  static const expand = LucideIcons.maximize2;
  static const collapse = LucideIcons.minimize2;
  static const expandLess = LucideIcons.chevronUp;
  static const expandMore = LucideIcons.chevronDown;
  static const visibility = LucideIcons.eye;
  static const visibilityOff = LucideIcons.eyeOff;
  static const star = LucideIcons.star;
  static const starOutline = LucideIcons.star;
  static const favorite = LucideIcons.heart;
  static const favoriteOutline = LucideIcons.heart;

  // Flash & Camera
  static const flashOn = LucideIcons.zap;
  static const flashOff = LucideIcons.zapOff;

  // Miscellaneous
  static const calendar = LucideIcons.calendar;
  static const clock = LucideIcons.clock;
  static const badge = LucideIcons.badge;
  static const flag = LucideIcons.flag;
  static const flagOutline = LucideIcons.flag;
  static const gavel = LucideIcons.gavel;
  static const importExport = LucideIcons.arrowDownUp;
  static const inventory = LucideIcons.package;
  static const inbox = LucideIcons.inbox;

  // Helper method to create Icon widget
  static Icon icon(IconData iconData, {Color? color, double? size}) {
    return Icon(iconData, color: color, size: size);
  }
}
