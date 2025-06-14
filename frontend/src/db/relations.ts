import { relations } from "drizzle-orm/relations";
import { usersInAuth, features, artists, artistPlacements, events, eventSets, featureVotes, artistPlacementHistory, profiles, userActivities, userLevels, roles, xpRewards, artistMembers, eventSetArtists, firstTimeRankings, activityRewards } from "./schema";

export const featuresRelations = relations(features, ({one, many}) => ({
	usersInAuth: one(usersInAuth, {
		fields: [features.createdBy],
		references: [usersInAuth.id]
	}),
	featureVotes: many(featureVotes),
}));

export const usersInAuthRelations = relations(usersInAuth, ({many}) => ({
	features: many(features),
	artistPlacements: many(artistPlacements),
	featureVotes: many(featureVotes),
	events: many(events),
	artistPlacementHistories: many(artistPlacementHistory),
	profiles: many(profiles),
	userActivities: many(userActivities),
	artists: many(artists),
	userLevels: many(userLevels),
	roles: many(roles),
	xpRewards: many(xpRewards),
	firstTimeRankings: many(firstTimeRankings),
}));

export const artistPlacementsRelations = relations(artistPlacements, ({one}) => ({
	artist: one(artists, {
		fields: [artistPlacements.artistId],
		references: [artists.id]
	}),
	usersInAuth: one(usersInAuth, {
		fields: [artistPlacements.userId],
		references: [usersInAuth.id]
	}),
}));

export const artistsRelations = relations(artists, ({one, many}) => ({
	artistPlacements: many(artistPlacements),
	artistPlacementHistories: many(artistPlacementHistory),
	userActivities: many(userActivities),
	usersInAuth: one(usersInAuth, {
		fields: [artists.createdBy],
		references: [usersInAuth.id]
	}),
	artistMembers_memberArtistId: many(artistMembers, {
		relationName: "artistMembers_memberArtistId_artists_id"
	}),
	artistMembers_parentArtistId: many(artistMembers, {
		relationName: "artistMembers_parentArtistId_artists_id"
	}),
	eventSetArtists: many(eventSetArtists),
	firstTimeRankings: many(firstTimeRankings),
}));

export const eventSetsRelations = relations(eventSets, ({one, many}) => ({
	event: one(events, {
		fields: [eventSets.eventId],
		references: [events.id]
	}),
	userActivities: many(userActivities),
	eventSetArtists: many(eventSetArtists),
}));

export const eventsRelations = relations(events, ({one, many}) => ({
	eventSets: many(eventSets),
	usersInAuth: one(usersInAuth, {
		fields: [events.createdBy],
		references: [usersInAuth.id]
	}),
	userActivities: many(userActivities),
}));

export const featureVotesRelations = relations(featureVotes, ({one}) => ({
	feature: one(features, {
		fields: [featureVotes.featureId],
		references: [features.id]
	}),
	usersInAuth: one(usersInAuth, {
		fields: [featureVotes.userId],
		references: [usersInAuth.id]
	}),
}));

export const artistPlacementHistoryRelations = relations(artistPlacementHistory, ({one}) => ({
	artist: one(artists, {
		fields: [artistPlacementHistory.artistId],
		references: [artists.id]
	}),
	usersInAuth: one(usersInAuth, {
		fields: [artistPlacementHistory.userId],
		references: [usersInAuth.id]
	}),
}));

export const profilesRelations = relations(profiles, ({one}) => ({
	usersInAuth: one(usersInAuth, {
		fields: [profiles.id],
		references: [usersInAuth.id]
	}),
}));

export const userActivitiesRelations = relations(userActivities, ({one, many}) => ({
	artist: one(artists, {
		fields: [userActivities.artistId],
		references: [artists.id]
	}),
	event: one(events, {
		fields: [userActivities.eventId],
		references: [events.id]
	}),
	eventSet: one(eventSets, {
		fields: [userActivities.setId],
		references: [eventSets.id]
	}),
	usersInAuth: one(usersInAuth, {
		fields: [userActivities.userId],
		references: [usersInAuth.id]
	}),
	activityRewards: many(activityRewards),
}));

export const userLevelsRelations = relations(userLevels, ({one}) => ({
	usersInAuth: one(usersInAuth, {
		fields: [userLevels.userId],
		references: [usersInAuth.id]
	}),
}));

export const rolesRelations = relations(roles, ({one}) => ({
	usersInAuth: one(usersInAuth, {
		fields: [roles.userId],
		references: [usersInAuth.id]
	}),
}));

export const xpRewardsRelations = relations(xpRewards, ({one, many}) => ({
	usersInAuth: one(usersInAuth, {
		fields: [xpRewards.userId],
		references: [usersInAuth.id]
	}),
	activityRewards: many(activityRewards),
}));

export const artistMembersRelations = relations(artistMembers, ({one}) => ({
	artist_memberArtistId: one(artists, {
		fields: [artistMembers.memberArtistId],
		references: [artists.id],
		relationName: "artistMembers_memberArtistId_artists_id"
	}),
	artist_parentArtistId: one(artists, {
		fields: [artistMembers.parentArtistId],
		references: [artists.id],
		relationName: "artistMembers_parentArtistId_artists_id"
	}),
}));

export const eventSetArtistsRelations = relations(eventSetArtists, ({one}) => ({
	artist: one(artists, {
		fields: [eventSetArtists.artistId],
		references: [artists.id]
	}),
	eventSet: one(eventSets, {
		fields: [eventSetArtists.setId],
		references: [eventSets.id]
	}),
}));

export const firstTimeRankingsRelations = relations(firstTimeRankings, ({one}) => ({
	artist: one(artists, {
		fields: [firstTimeRankings.artistId],
		references: [artists.id]
	}),
	usersInAuth: one(usersInAuth, {
		fields: [firstTimeRankings.userId],
		references: [usersInAuth.id]
	}),
}));

export const activityRewardsRelations = relations(activityRewards, ({one}) => ({
	userActivity: one(userActivities, {
		fields: [activityRewards.activityId],
		references: [userActivities.id]
	}),
	xpReward: one(xpRewards, {
		fields: [activityRewards.rewardId],
		references: [xpRewards.id]
	}),
}));