{if	$bIsShowStatsPerformance and ({cfg name='misc.debug'} == true)}
	<div class="stat-performance">
		{hook run='statistics_performance_begin'}
		<table>
			<tr>
				<td>
					<h4>MySql</h4>
					query: <strong>{$aStatsPerformance.sql.count}</strong><br />
					time: <strong>{$aStatsPerformance.sql.time}</strong>
					queries: <pre>{$aStatsPerformance.sql.query_log}</pre>
				</td>
				<td>
					<h4>PHP</h4>	
					time load modules: <strong>{$aStatsPerformance.engine.time_load_module}</strong><br />
					full time: <strong>{$iTimeFullPerformance}</strong>
				</td>
				{hook run='statistics_performance_item'}
			</tr>
		</table>
		{hook run='statistics_performance_end'}
	</div>
{/if}
