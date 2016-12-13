#!/usr/bin/php

<?php
/**
 *
 */

$args = _parseArgs();

$networkInfoJson = $args['i'] ?: 'network.json';
$host = $args['h'] ?: 'pon.com';
$hostSuffix = $args['s'] ?: '-docker-auto';

$dnsmasqConfigFile = $host . $hostSuffix;

$json = trim(file_get_contents(__DIR__ . DIRECTORY_SEPARATOR . $networkInfoJson));
if (empty($json)) {
    exit ('');
}
$networkData = json_decode($json, 1)[0];

if (!empty($networkData) && isset($networkData['Containers']) && is_array($networkData['Containers'])) {
    $hosts = [];
    foreach ($networkData['Containers'] as $id => $info) {
        if (isset($info['Name'], $info['IPv4Address'])) {
            $hosts[str_replace('/16', '', $info['IPv4Address'])] = str_replace('pon-', '', $info['Name']) . '.' . $host;
        }
    }

    /**
     * Write config file for dnsmasq
     */
    if (!empty($hosts)) {
        $fp = fopen($dnsmasqConfigFile, 'w');
        if (is_resource($fp)) {
            foreach ($hosts as $ip => $name) {
                fwrite($fp, "address=/{$name}/{$ip}" . PHP_EOL);
            }
            fclose($fp);
            exit($dnsmasqConfigFile);
        }
    }
}

exit('');

/**
 * Parse input arguments
 *
 * @return array
 */
function _parseArgs()
{
    $current = null;
    $_args = [];

    foreach ($_SERVER['argv'] as $arg) {
        $match = array();
        if (preg_match('#^--([\w\d_-]{1,})$#', $arg, $match) || preg_match('#^-([\w\d_]{1,})$#', $arg, $match)) {
            $current = $match[1];
            $_args[$current] = true;
        } else {
            if ($current) {
                $_args[$current] = $arg;
            } else if (preg_match('#^([\w\d_]{1,})$#', $arg, $match)) {
                $_args[$match[1]] = true;
            }
        }
    }
    return $_args;
}

?>
