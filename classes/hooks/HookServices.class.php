<?php

class HookServices extends Hook
{
    public function RegisterHook()
    {
        $this->AddHook('template_quotes', 'Quotes', __CLASS__, -100);
    }

    private function getJSON($sServiceName) {
        $ch = curl_init();

        $sServiceURL = Config::Get('misc.services')[$sServiceName];

        // Url
        curl_setopt($ch, CURLOPT_URL, $sServiceURL);
        // 1s timeout time for cURL connection (assume that connection is fast enough)
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 1);
        // Return data to variable
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $data = curl_exec($ch);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            return false;
        }

        return json_decode($data, true);
    }

    public function Quotes()
    {
        $sNotFound = "¯\\_(ツ)_/¯";

        $aDecoded = $this->getJSON("twicher");

        if (array_key_exists('text', $aDecoded)) {
            return $aDecoded['text'];
        } else {
            return $sNotFound;
        }

    }

}
