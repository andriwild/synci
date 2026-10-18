import {Button, DatePicker, Form, Input, Modal, notification, Select, Switch, TimePicker} from "antd";
import dayjs, {Dayjs} from "dayjs";
import {useEffect} from "react";
import {organisationApi} from "../../../services/organisation/organisationApi.ts";
import {stringifyApiError} from "../../../services/common/apiHelpers.ts";
import {MyOrganisation} from "../../../services/organisation/entities/organisation.ts";
import {SportEvent} from "../../../services/event/entities/event.ts";
import {useResponsive} from "../../../utils/useResponsive.ts";
import "../Organisation.css";

const LOCAL_DATE_TIME = "YYYY-MM-DDTHH:mm:ss";
const TIME_FORMAT = "HH:mm";

type FormValues = {
    name: string;
    sportId: string;
    allDay: boolean;
    startsOn: Dayjs;
    endsOn?: Dayjs;
    /** mobile only: time of day entered separately from the date */
    startsTime?: Dayjs;
    endsTime?: Dayjs;
    location?: string;
    description?: string;
};

/** Desktop pickers carry the time in the date; on mobile it comes from the separate time field. */
const combine = (date: Dayjs, time?: Dayjs) =>
    time ? date.hour(time.hour()).minute(time.minute()).second(0) : date;

/**
 * Create or edit an organisation event. The event belongs to the organisation itself (root node)
 * or to one of its groups. An all-day event is stored without an end.
 *
 * On phones the combined date+time picker panel is wider than the screen, so date and time are
 * two separate controls there and merged on submit.
 */
export const OrganisationEventFormModal = ({organisation, open, onClose, event, defaultSportId}: {
    organisation: MyOrganisation,
    open: boolean,
    onClose: () => void,
    event?: SportEvent,
    defaultSportId?: string
}) => {
    const [form] = Form.useForm<FormValues>();
    const [api, contextHolder] = notification.useNotification();
    const [createEvent, createStatus] = organisationApi.useCreateEventMutation();
    const [updateEvent, updateStatus] = organisationApi.useUpdateEventMutation();
    const allDay = Form.useWatch("allDay", form);
    const {isMobile} = useResponsive();
    const splitTime = isMobile;

    useEffect(() => {
        if (!open) return;
        if (event) {
            const startsOn = dayjs(event.startsOn);
            const endsOn = event.endsOn ? dayjs(event.endsOn) : undefined;
            form.setFieldsValue({
                name: event.name,
                sportId: event.sportId,
                allDay: !event.endsOn,
                startsOn,
                endsOn,
                startsTime: startsOn,
                endsTime: endsOn,
                location: event.location,
                description: event.description,
            });
        } else {
            form.resetFields();
            form.setFieldsValue({sportId: defaultSportId ?? organisation.sport.id, allDay: false});
        }
    }, [open, event, defaultSportId, organisation.sport.id, form]);

    const resolveStart = (values: FormValues) =>
        values.allDay ? values.startsOn.startOf("day") : combine(values.startsOn, splitTime ? values.startsTime : undefined);

    const resolveEnd = (values: FormValues) =>
        values.allDay || !values.endsOn ? undefined : combine(values.endsOn, splitTime ? values.endsTime : undefined);

    const handleSubmit = async (values: FormValues) => {
        const body = {
            name: values.name,
            sportId: values.sportId,
            location: values.location,
            description: values.description,
            startsOn: resolveStart(values).format(LOCAL_DATE_TIME),
            endsOn: resolveEnd(values)?.format(LOCAL_DATE_TIME),
        };
        const result = event
            ? await updateEvent({organisationId: organisation.id, eventId: event.id, ...body})
            : await createEvent({organisationId: organisation.id, ...body});
        if (result.error) {
            api.error({message: "Event konnte nicht gespeichert werden", description: stringifyApiError(result.error), placement: "bottomRight"});
            return;
        }
        api.success({message: event ? "Event aktualisiert" : "Event erfasst", placement: "bottomRight"});
        onClose();
    };

    const sportOptions = [
        {value: organisation.sport.id, label: `${organisation.name} (ganze Organisation)`},
        ...organisation.sport.subSports.map((group) => ({value: group.id, label: group.label})),
    ];

    const endNotBeforeStart = ({getFieldsValue}: { getFieldsValue: () => FormValues }) => ({
        validator: () => {
            const values = getFieldsValue();
            if (!values.startsOn || !values.endsOn) return Promise.resolve();
            const start = resolveStart(values);
            const end = resolveEnd(values);
            if (!end || !end.isBefore(start)) return Promise.resolve();
            return Promise.reject(new Error("Das Ende darf nicht vor dem Beginn liegen"));
        }
    });

    const dateFormat = allDay || splitTime ? "DD.MM.YYYY" : "DD.MM.YYYY HH:mm";
    const showTime = allDay || splitTime ? false : {format: TIME_FORMAT, minuteStep: 5 as const};

    return (
        <>
            {contextHolder}
            <Modal title={event ? "Event bearbeiten" : "Event erfassen"} open={open} onCancel={onClose} footer={null}>
                <Form
                    form={form}
                    layout="vertical"
                    onFinish={handleSubmit}
                    initialValues={{allDay: false}}
                    // Enter inside the date pickers must only confirm the date, not submit the whole form
                    onKeyDown={(e) => {
                        if (e.key === "Enter" && (e.target as HTMLElement).tagName !== "TEXTAREA") e.preventDefault();
                    }}
                >
                    <Form.Item
                        label="Name"
                        name="name"
                        rules={[
                            {required: true, whitespace: true, message: "Bitte einen Namen eingeben"},
                            {max: 100, message: "Höchstens 100 Zeichen"}
                        ]}
                    >
                        <Input placeholder="z.B. Training, Heimspiel, GV"/>
                    </Form.Item>
                    <Form.Item label="Gehört zu" name="sportId" rules={[{required: true, message: "Bitte wählen"}]}>
                        <Select options={sportOptions}/>
                    </Form.Item>
                    <Form.Item label="Ganztägig" name="allDay" valuePropName="checked">
                        <Switch/>
                    </Form.Item>

                    <div className="event-form-row">
                        <Form.Item
                            label="Beginn"
                            name="startsOn"
                            rules={[{required: true, message: "Bitte Beginn wählen"}]}
                        >
                            <DatePicker showTime={showTime} format={dateFormat} inputReadOnly={isMobile} style={{width: "100%"}}/>
                        </Form.Item>
                        {splitTime && !allDay &&
                            <Form.Item
                                label="Uhrzeit"
                                name="startsTime"
                                className="event-form-row__time"
                                rules={[{required: true, message: "Bitte Uhrzeit wählen"}]}
                            >
                                <TimePicker format={TIME_FORMAT} minuteStep={5} inputReadOnly style={{width: "100%"}}/>
                            </Form.Item>}
                    </div>

                    {!allDay &&
                        <div className="event-form-row">
                            <Form.Item
                                label="Ende"
                                name="endsOn"
                                dependencies={["startsOn", "startsTime", "endsTime"]}
                                rules={[{required: true, message: "Bitte Ende wählen"}, endNotBeforeStart]}
                            >
                                <DatePicker showTime={showTime} format={dateFormat} inputReadOnly={isMobile} style={{width: "100%"}}/>
                            </Form.Item>
                            {splitTime &&
                                <Form.Item
                                    label="Uhrzeit"
                                    name="endsTime"
                                    className="event-form-row__time"
                                    rules={[{required: true, message: "Bitte Uhrzeit wählen"}]}
                                >
                                    <TimePicker format={TIME_FORMAT} minuteStep={5} inputReadOnly style={{width: "100%"}}/>
                                </Form.Item>}
                        </div>}

                    <Form.Item label="Ort" name="location" rules={[{max: 255, message: "Höchstens 255 Zeichen"}]}>
                        <Input placeholder="z.B. Sporthalle Musterstadt"/>
                    </Form.Item>
                    <Form.Item label="Beschreibung" name="description">
                        <Input.TextArea rows={3}/>
                    </Form.Item>
                    <Form.Item style={{marginBottom: 0}}>
                        <Button type="primary" htmlType="submit" loading={createStatus.isLoading || updateStatus.isLoading}>
                            Speichern
                        </Button>
                    </Form.Item>
                </Form>
            </Modal>
        </>
    );
};
