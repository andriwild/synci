import {FC} from "react";
import {Button, Card, Flex, Result, Skeleton, Typography} from "antd";
import {IconCalendarEvent, IconCheck, IconMapPin, IconX} from "@tabler/icons-react";
import {useParams} from "react-router-dom";
import {invitationApi} from "../../services/invitation/invitationApi.ts";
import {EventAnswer, EventInvitation} from "../../services/organisation/entities/organisation.ts";
import {formatDayHeading, formatTime} from "../../services/common/dateUtil.ts";
import {isHttpError, stringifyApiError} from "../../services/common/apiHelpers.ts";
import {usePageMeta} from "../../utils/usePageMeta.ts";

const {Title, Text, Paragraph} = Typography;

const errorTitle = (error: unknown) => {
    switch (isHttpError(error) ? error.status : undefined) {
        case 404:
            return "Dieser Link ist nicht mehr gültig";
        case 403:
            return "Du bist nicht mehr Mitglied dieser Organisation";
        case 400:
            return "Für dieses Event werden keine Antworten mehr gesammelt";
        default:
            return stringifyApiError(error as never);
    }
};

const when = (invitation: EventInvitation) => invitation.endsOn
    ? `${formatDayHeading(invitation.startsOn)}, ${formatTime(invitation.startsOn)} – ${formatTime(invitation.endsOn)}`
    : `${formatDayHeading(invitation.startsOn)}, ganztägig`;

const status: Record<EventAnswer, string> = {YES: "Du hast zugesagt.", NO: "Du hast abgesagt."};

/** Opened from the link in a calendar event: the owner of the calendar answers yes or no without logging in. */
export const AnswerPage: FC = () => {
    usePageMeta("Zu- oder absagen");
    const {configId = "", eventId = ""} = useParams();
    const {data: invitation, error, isLoading} = invitationApi.useGetQuery({configId, eventId});
    const [answer, answerStatus] = invitationApi.useAnswerMutation();

    const choose = (value: EventAnswer) => answer({configId, eventId, answer: value});

    return (
        <Flex justify="center" style={{width: "100%", height: "100%", overflowY: "auto", padding: 16}}>
            <Card style={{maxWidth: 480, width: "100%", alignSelf: "flex-start"}}>
                {isLoading && <Skeleton active/>}
                {error && <Result status="warning" title={errorTitle(error)}/>}
                {invitation &&
                    <Flex vertical gap={16}>
                        <div>
                            <Text type="secondary">{invitation.organisation}</Text>
                            <Title level={3} style={{margin: 0}}>{invitation.name}</Title>
                        </div>
                        <Flex vertical gap={4}>
                            <Text><IconCalendarEvent size={16} style={{verticalAlign: "-3px"}}/> {when(invitation)}</Text>
                            {invitation.location &&
                                <Text><IconMapPin size={16} style={{verticalAlign: "-3px"}}/> {invitation.location}</Text>}
                        </Flex>
                        <Title level={5} style={{margin: 0}}>Bist du dabei?</Title>
                        <Flex gap={8} wrap>
                            <Button
                                size="large"
                                type={invitation.answer === "YES" ? "primary" : "default"}
                                icon={<IconCheck size={18}/>}
                                loading={answerStatus.isLoading && answerStatus.originalArgs?.answer === "YES"}
                                onClick={() => choose("YES")}
                            >
                                Ja, ich bin dabei
                            </Button>
                            <Button
                                size="large"
                                danger={invitation.answer === "NO"}
                                type={invitation.answer === "NO" ? "primary" : "default"}
                                icon={<IconX size={18}/>}
                                loading={answerStatus.isLoading && answerStatus.originalArgs?.answer === "NO"}
                                onClick={() => choose("NO")}
                            >
                                Nein, ich kann nicht
                            </Button>
                        </Flex>
                        {answerStatus.error && <Text type="danger">{errorTitle(answerStatus.error)}</Text>}
                        <Paragraph type="secondary" style={{margin: 0}}>
                            {invitation.answer ? status[invitation.answer] : "Du hast noch nicht geantwortet."}{" "}
                            Über den Link im Kalender kannst du deine Antwort jederzeit ändern.
                        </Paragraph>
                    </Flex>}
            </Card>
        </Flex>
    );
};
