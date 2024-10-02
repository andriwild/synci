import {Button, Card, Flex, Form} from "antd";
import {useNavigate, useParams} from "react-router-dom";
import {useEffect, useState} from "react";
import {TeamSelect} from "../components/TeamSelect.tsx";
import {SyncConfig} from "../model/SyncConfig.ts";
import {useForm} from "antd/es/form/Form";


export const UserConfigForm = () => {
    const [form] = useForm();
    const navigate = useNavigate();
    const {id} = useParams();
    const createmode = id === 'create';

    const [syncConfig, setSyncConfig] = useState<SyncConfig>({
        id: '',
        url: '',
        teams: []
    });
    console.log('SyncConfig:', syncConfig);

    useEffect(() => {
        fetch('http://localhost:8080/api/syncconfig/' + id)
            .then(response => response.json())
            .then(data => {
                    setSyncConfig(data);
                }
            );
    }, []);


    const handleSubmit = (values: any) => {
        console.log('Form submitted:', values);
        console.log('Form on sub:', form.getFieldValue('teams'));
        if (createmode) {
        fetch('http://localhost:8080/api/syncconfig/' + id, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(form.getFieldsValue()),
        })
            .then(response => response.json())
            .then(data => {
                    console.log(data);
                    setSyncConfig(data);
                }
            )
            .catch(error => console.error('Error:', error));
        } else {
            fetch('http://localhost:8080/api/syncconfig/' + id, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(form.getFieldsValue()),
            })
                .then(response => response.json())
                .then(data => {
                        console.log(data);
                        setSyncConfig(data);
                    }
                )
                .catch(error => console.error('Error:', error));
        }
    };

    const handleBack = () => {
        console.log('Zurück-Button geklickt');
        navigate('/');
    };

    console.log("Form", form.getFieldValue('teams'));

    return (
        <Flex vertical style={{height: '100%', width: '100%', padding: 24}}>
        <Card style={{ width: 600, textAlign: 'left' }}>
            {/*<h2 style={{ marginBottom: '20px' }}>Abonement {syncConfig.}</h2>*/}
            <p>Füge eine Konfiguration hinzu. Wähle dabei aus, für welches Team, welchen Sportler, welchen Ort oder
                welche Sportart du dich interessierst</p>
            <Form form={form} onFinish={handleSubmit} layout={'vertical'} style={{marginTop: 36}}>
                <Form.Item name={'teams'} label={'Teams'}>
                    <TeamSelect  onChange={(value) => form.setFieldsValue({teams: value})}/>
                </Form.Item>
                <Flex gap={'middle'} justify={'end'} style={{marginTop: 48, marginBottom: 12 }}>
                    <Button onClick={handleBack}>
                        Zurück
                    </Button>
                    <Button htmlType={'submit'} type={'primary'}>
                        Submit
                    </Button>
                </Flex>
            </Form>
             </Card>
        </Flex>
    );
};
