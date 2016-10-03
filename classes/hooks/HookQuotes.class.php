<?php

class HookQuotes extends Hook
{
    public function RegisterHook()
    {
        $this->AddHook('template_quotes', 'Quotes', __CLASS__, -100);
    }

    public function Quotes()
    {
        $sNotFound = "¯\\_(ツ)_/¯";

        $ch = curl_init();
        // Url
        curl_setopt($ch, CURLOPT_URL, Config::Get('misc.twicher.url'));
        // 1s timeout time for cURL connection (assume that connection is fast enough)
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 1);
        // Return data to variable
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $data = curl_exec($ch);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            return $sNotFound;
        }

        $aDecoded = json_decode($data, true);

        if (array_key_exists('text', $aDecoded)) {
            return $aDecoded['text'];
        } else {
            return $sNotFound;
        }

    }
}
