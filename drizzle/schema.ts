import { boolean, index, int, mysqlEnum, mysqlTable, text, timestamp, varchar } from "drizzle-orm/mysql-core";

export const users = mysqlTable("users", {
  id: int("id").autoincrement().primaryKey(),
  openId: varchar("openId", { length: 64 }).notNull().unique(),
  name: text("name"),
  email: varchar("email", { length: 320 }),
  loginMethod: varchar("loginMethod", { length: 64 }),
  role: mysqlEnum("role", ["user", "admin"]).default("user").notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  lastSignedIn: timestamp("lastSignedIn").defaultNow().notNull(),
});

export const entitlements = mysqlTable("entitlements", {
  entitlementId: varchar("entitlementId", { length: 64 }).primaryKey(),
  userId: int("userId").notNull(),
  platform: mysqlEnum("platform", ["android", "ios", "steam"]).notNull(),
  productId: varchar("productId", { length: 128 }).notNull(),
  status: mysqlEnum("status", ["active", "pending", "revoked", "refunded", "expired"]).notNull(),
  originalTransactionId: varchar("originalTransactionId", { length: 512 }).notNull(),
  latestTransactionId: varchar("latestTransactionId", { length: 512 }).notNull(),
  verifiedAt: timestamp("verifiedAt"),
  lastVerifiedAt: timestamp("lastVerifiedAt"),
  sourceStore: varchar("sourceStore", { length: 64 }).notNull(),
  signedEntitlementVersion: int("signedEntitlementVersion").default(1).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
}, (table) => [index("entitlements_user_idx").on(table.userId), index("entitlements_tx_idx").on(table.latestTransactionId)]);

export const purchaseTransactions = mysqlTable("purchase_transactions", {
  transactionId: varchar("transactionId", { length: 512 }).primaryKey(),
  userId: int("userId").notNull(),
  platform: mysqlEnum("platform", ["android", "ios"]).notNull(),
  productId: varchar("productId", { length: 128 }).notNull(),
  validationStatus: mysqlEnum("validationStatus", ["pending", "verified", "rejected", "revoked", "refunded"]).notNull(),
  validationReason: varchar("validationReason", { length: 256 }),
  verifiedAt: timestamp("verifiedAt"),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
}, (table) => [index("purchase_transactions_user_idx").on(table.userId)]);

export const consentRecords = mysqlTable("consent_records", {
  id: int("id").autoincrement().primaryKey(),
  userId: int("userId"),
  platform: mysqlEnum("platform", ["android", "ios", "web"]).notNull(),
  adsAllowed: boolean("adsAllowed").notNull(),
  personalizedAdsAllowed: boolean("personalizedAdsAllowed").notNull(),
  policyVersion: varchar("policyVersion", { length: 32 }).notNull(),
  decidedAt: timestamp("decidedAt").defaultNow().notNull(),
}, (table) => [index("consent_records_user_idx").on(table.userId)]);

export const matches = mysqlTable("matches", {
  matchId: varchar("matchId", { length: 64 }).primaryKey(),
  mode: mysqlEnum("mode", ["free_for_all", "team_deathmatch", "capture_the_flag"]).notNull(),
  transport: mysqlEnum("transport", ["lan_enet", "steam_p2p", "dedicated_future"]).notNull(),
  state: mysqlEnum("state", ["lobby", "active", "results", "aborted"]).notNull(),
  hostUserId: int("hostUserId"),
  lobbyCode: varchar("lobbyCode", { length: 12 }),
  startedAt: timestamp("startedAt"),
  endedAt: timestamp("endedAt"),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
}, (table) => [index("matches_host_idx").on(table.hostUserId), index("matches_lobby_idx").on(table.lobbyCode)]);

export const matchParticipants = mysqlTable("match_participants", {
  id: int("id").autoincrement().primaryKey(),
  matchId: varchar("matchId", { length: 64 }).notNull(),
  userId: int("userId"),
  playerName: varchar("playerName", { length: 32 }).notNull(),
  team: mysqlEnum("team", ["none", "crimson", "violet"]).default("none").notNull(),
  kills: int("kills").default(0).notNull(),
  deaths: int("deaths").default(0).notNull(),
  score: int("score").default(0).notNull(),
  joinedAt: timestamp("joinedAt").defaultNow().notNull(),
}, (table) => [index("match_participants_match_idx").on(table.matchId)]);

export type User = typeof users.$inferSelect;
export type InsertUser = typeof users.$inferInsert;

