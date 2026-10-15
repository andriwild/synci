import {Sport} from "../../../services/sport/entities/sport.ts";
import {MyOrganisation} from "../../../services/organisation/entities/organisation.ts";

/**
 * A row in the sport tree. Organisations and their groups are ordinary sport nodes that carry a
 * reference to their organisation; "Organisationen entdecken" is the only special row.
 */
export type TreeNode =
    | { kind: "sport"; id: string; label: string; sport: Sport; organisation?: MyOrganisation }
    | { kind: "discover"; id: "discover"; label: string };

export const DISCOVER_NODE: TreeNode = {kind: "discover", id: "discover", label: "Organisationen entdecken"};

export const sportNode = (sport: Sport, organisation?: MyOrganisation): TreeNode =>
    ({kind: "sport", id: sport.id, label: sport.label, sport, organisation});

/** Only approved memberships show up in the tree; pending ones are listed on the organisations page. */
export const activeOrganisations = (organisations?: MyOrganisation[]): MyOrganisation[] =>
    (organisations ?? []).filter((organisation) => organisation.status === "ACTIVE");

/** Own organisations first, then the discover row, then the public sports. */
export const firstColumn = (sports: Sport[], organisations: MyOrganisation[], loggedIn: boolean): TreeNode[] => [
    ...organisations.map((organisation) => sportNode(organisation.sport, organisation)),
    ...(loggedIn ? [DISCOVER_NODE] : []),
    ...sports.map((sport) => sportNode(sport))
];

export const childNodes = (node: TreeNode): TreeNode[] =>
    node.kind === "sport" ? node.sport.subSports.map((sub) => sportNode(sub, node.organisation)) : [];

export const hasChildren = (node: TreeNode) => childNodes(node).length > 0;

/**
 * Organisation nodes in a selection can go stale (a group was added, the user left the organisation).
 * Re-resolve the node against the latest data; returns null when it no longer exists.
 */
export const withLiveOrganisation = (node: TreeNode, organisations: MyOrganisation[]): TreeNode | null => {
    if (node.kind !== "sport" || !node.organisation) return node;
    const live = organisations.find((organisation) => organisation.id === node.organisation?.id);
    if (!live) return null;
    const sport = live.sport.id === node.sport.id ? live.sport : live.sport.subSports.find((group) => group.id === node.sport.id);
    if (!sport) return null;
    return sportNode(sport, live);
};
