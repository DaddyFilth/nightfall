CREATE TABLE `consent_records` (
	`id` int AUTO_INCREMENT NOT NULL,
	`userId` int,
	`platform` enum('android','ios','web') NOT NULL,
	`adsAllowed` boolean NOT NULL,
	`personalizedAdsAllowed` boolean NOT NULL,
	`policyVersion` varchar(32) NOT NULL,
	`decidedAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `consent_records_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `entitlements` (
	`entitlementId` varchar(64) NOT NULL,
	`userId` int NOT NULL,
	`platform` enum('android','ios','steam') NOT NULL,
	`productId` varchar(128) NOT NULL,
	`status` enum('active','pending','revoked','refunded','expired') NOT NULL,
	`originalTransactionId` varchar(512) NOT NULL,
	`latestTransactionId` varchar(512) NOT NULL,
	`verifiedAt` timestamp,
	`lastVerifiedAt` timestamp,
	`sourceStore` varchar(64) NOT NULL,
	`signedEntitlementVersion` int NOT NULL DEFAULT 1,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `entitlements_entitlementId` PRIMARY KEY(`entitlementId`)
);
--> statement-breakpoint
CREATE TABLE `match_participants` (
	`id` int AUTO_INCREMENT NOT NULL,
	`matchId` varchar(64) NOT NULL,
	`userId` int,
	`playerName` varchar(32) NOT NULL,
	`team` enum('none','crimson','violet') NOT NULL DEFAULT 'none',
	`kills` int NOT NULL DEFAULT 0,
	`deaths` int NOT NULL DEFAULT 0,
	`score` int NOT NULL DEFAULT 0,
	`joinedAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `match_participants_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `matches` (
	`matchId` varchar(64) NOT NULL,
	`mode` enum('free_for_all','team_deathmatch','capture_the_flag') NOT NULL,
	`transport` enum('lan_enet','steam_p2p','dedicated_future') NOT NULL,
	`state` enum('lobby','active','results','aborted') NOT NULL,
	`hostUserId` int,
	`lobbyCode` varchar(12),
	`startedAt` timestamp,
	`endedAt` timestamp,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `matches_matchId` PRIMARY KEY(`matchId`)
);
--> statement-breakpoint
CREATE TABLE `purchase_transactions` (
	`transactionId` varchar(512) NOT NULL,
	`userId` int NOT NULL,
	`platform` enum('android','ios') NOT NULL,
	`productId` varchar(128) NOT NULL,
	`validationStatus` enum('pending','verified','rejected','revoked','refunded') NOT NULL,
	`validationReason` varchar(256),
	`verifiedAt` timestamp,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `purchase_transactions_transactionId` PRIMARY KEY(`transactionId`)
);
--> statement-breakpoint
CREATE INDEX `consent_records_user_idx` ON `consent_records` (`userId`);--> statement-breakpoint
CREATE INDEX `entitlements_user_idx` ON `entitlements` (`userId`);--> statement-breakpoint
CREATE INDEX `entitlements_tx_idx` ON `entitlements` (`latestTransactionId`);--> statement-breakpoint
CREATE INDEX `match_participants_match_idx` ON `match_participants` (`matchId`);--> statement-breakpoint
CREATE INDEX `matches_host_idx` ON `matches` (`hostUserId`);--> statement-breakpoint
CREATE INDEX `matches_lobby_idx` ON `matches` (`lobbyCode`);--> statement-breakpoint
CREATE INDEX `purchase_transactions_user_idx` ON `purchase_transactions` (`userId`);