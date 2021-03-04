import React, { ReactElement, ReactNode } from "react";
import _ from "lodash";

import { Col, Box, Text } from "@tlon/indigo-react";
import {
  Invites as IInvites,
  Associations,
  Invite,
  JoinRequests,
  Groups,
  Contacts,
  AppInvites,
  JoinProgress,
  JoinRequest,
} from "@urbit/api";

import GlobalApi from "~/logic/api/global";
import { resourceAsPath, alphabeticalOrder } from "~/logic/lib/util";
import InviteItem from "~/views/components/Invite";

interface InvitesProps {
  api: GlobalApi;
  invites: IInvites;
  groups: Groups;
  contacts: Contacts;
  associations: Associations;
  pendingJoin: JoinRequests;
}

interface InviteRef {
  uid: string;
  app: string;
  invite: Invite;
}

export function Invites(props: InvitesProps): ReactNode {
  const { api, invites } = props;

  const inviteArr: InviteRef[] = _.reduce(
    invites,
    (acc: InviteRef[], val: AppInvites, app: string) => {
      const appInvites = _.reduce(
        val,
        (invs: InviteRef[], invite: Invite, uid: string) => {
          return [...invs, { invite, uid, app }];
        },
        []
      );
      return [...acc, ...appInvites];
    },
    []
  );

  const pendingJoin = _.omitBy(props.pendingJoin, "hidden");

  const invitesAndStatus: { [rid: string]: JoinRequest | InviteRef } = {
    ..._.keyBy(inviteArr, ({ invite }) => resourceAsPath(invite.resource)),
    ...pendingJoin,
  };

  return (
    <>
      {Object.keys(invitesAndStatus).length > 0 && (
        <Box position="sticky" zIndex={3} top="-1px" bg="white">
          <Box p="2" bg="scales.black05">
            <Text>Invites</Text>
          </Box>
        </Box>
      )}
      {Object.keys(invitesAndStatus)
        .sort(alphabeticalOrder)
        .map((resource) => {
          const inviteOrStatus = invitesAndStatus[resource];
          if ("progress" in inviteOrStatus) {
            return (
              <InviteItem
                key={resource}
                contacts={props.contacts}
                groups={props.groups}
                associations={props.associations}
                resource={resource}
                pendingJoin={pendingJoin}
                api={api}
              />
            );
          } else {
            const { app, uid, invite } = inviteOrStatus;
            console.log(inviteOrStatus);
            return (
              <InviteItem
                key={resource}
                api={api}
                invite={invite}
                app={app}
                uid={uid}
                pendingJoin={pendingJoin}
                resource={resource}
                contacts={props.contacts}
                groups={props.groups}
                associations={props.associations}
              />
            );
          }
        })}
    </>
  );
}
