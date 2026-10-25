import {Button, Flex, Modal, notification, Radio, Typography} from "antd";
import {IconCheck, IconCircleCheckFilled, IconCircleXFilled, IconHelpCircle, IconUsers, IconX} from "@tabler/icons-react";
import {useState} from "react";
import {SportEvent} from "../../../services/event/entities/event.ts";
import {EventAnswer, EventResponseSummary, MyOrganisation} from "../../../services/organisation/entities/organisation.ts";
import {organisationApi} from "../../../services/organisation/organisationApi.ts";
import {stringifyApiError} from "../../../services/common/apiHelpers.ts";

const answerOptions = [
    {value: "YES", label: <span className="event-answer__option"><IconCheck size={14}/>Ja</span>},
    {value: "NO", label: <span className="event-answer__option"><IconX size={14}/>Nein</span>},
];

/** Yes/no answer of the member to an event that asks for it, with the count of all answers. */
export const EventResponses = ({organisation, event}: { organisation: MyOrganisation, event: SportEvent }) => {
    const [api, contextHolder] = notification.useNotification();
    const {data} = organisationApi.useGetResponsesQuery(organisation.id);
    const [answer] = organisationApi.useAnswerMutation();
    // shown right away while the answer is saved
    const [pending, setPending] = useState<EventAnswer>();
    const [membersOpen, setMembersOpen] = useState(false);
    const summary = data?.find((s) => s.eventId === event.id);

    const choose = async (value: EventAnswer) => {
        setPending(value);
        const result = await answer({organisationId: organisation.id, eventId: event.id, answer: value});
        setPending(undefined);
        if (result.error) {
            api.error({message: "Antwort konnte nicht gespeichert werden", description: stringifyApiError(result.error), placement: "bottomRight"});
        }
    };

    const counts = summary && `${summary.yes} Ja · ${summary.no} Nein · ${summary.open} offen`;

    return (
        <Flex gap={8} align="center" wrap className="event-answer">
            {contextHolder}
            <Radio.Group
                size="small"
                optionType="button"
                buttonStyle="solid"
                aria-label={`Antwort für ${event.name}`}
                value={pending ?? summary?.myAnswer ?? undefined}
                onChange={(e) => choose(e.target.value)}
                options={answerOptions}
            />
            {summary?.members
                ? <Button type="link" size="small" icon={<IconUsers size={16}/>} onClick={() => setMembersOpen(true)}>
                    {counts}
                </Button>
                : <Typography.Text type="secondary" className="event-answer__counts">{counts}</Typography.Text>}
            {summary?.members &&
                <MembersModal title={event.name} summary={summary} open={membersOpen} onClose={() => setMembersOpen(false)}/>}
        </Flex>
    );
};

const sections = [
    {label: "Zusagen", answer: "YES", icon: <IconCircleCheckFilled size={18} color="#3D5A80"/>},
    {label: "Absagen", answer: "NO", icon: <IconCircleXFilled size={18} color="#D9363E"/>},
    {label: "Offen", answer: null, icon: <IconHelpCircle size={18} color="#8C96A3"/>},
] as const;

/** Who answered what; only admins get the names. */
const MembersModal = ({title, summary, open, onClose}: {
    title: string,
    summary: EventResponseSummary,
    open: boolean,
    onClose: () => void
}) => (
    <Modal title={title} open={open} onCancel={onClose} footer={null}>
        {sections.map((section) => {
            const members = (summary.members ?? []).filter((m) => m.answer === section.answer);
            return (
                <section key={section.label} className="event-answer__section">
                    <Typography.Text strong>{section.label} ({members.length})</Typography.Text>
                    <ul className="event-answer__members">
                        {members.map((member, index) => (
                            <li key={`${member.name}-${index}`}>{section.icon}{member.name ?? "Unbekannt"}</li>
                        ))}
                    </ul>
                </section>
            );
        })}
    </Modal>
);
